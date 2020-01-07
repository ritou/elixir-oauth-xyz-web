defmodule OAuthXYZ.Sample.DataHandler do
  @behaviour OAuthXYZ.Handler.DataHandler

  require Logger

  alias OAuthXYZ.Model.{
    Handle,
    Transaction,
    DisplayRequest,
    Interact,
    UserRequest,
    KeyRequest
  }

  alias OAuthXYZ.Repo
  alias OAuthXYZ.Sample.Model.Transaction, as: SampleTransaction

  @key4transaction Application.fetch_env!(:oauth_xyz, __MODULE__)
                   |> Keyword.fetch!(:key4transaction)
                   |> KittenBlue.JWK.from_compact()

  @handle_type_transaction "tx"

  @handle_type_interact_id "ii"

  @handle_type_access_token "at"

  @wait_sec 30

  @interact_id_expiration 60 * 60

  # TODO: from confiig
  @jwt_iss "http://localhost:4000"

  @spec create_transaction_handle() :: Handle.t()
  def create_transaction_handle() do
    Ulid.generate(System.system_time(:millisecond))
    |> do_create_transaction_handle()
  end

  defp do_create_transaction_handle(transaction_id) do
    iat = System.system_time(:second)

    {:ok, token} =
      %{
        "iss" => @jwt_iss,
        "handle" => @handle_type_transaction,
        "sub" => transaction_id,
        "iat" => iat
      }
      |> KittenBlue.JWS.sign(@key4transaction)

    Handle.new(%{value: token, type: :bearer})
  end

  @spec save_transaction(transaction :: Transaction.t()) :: :ok | {:error, :internal_error}
  def save_transaction(transaction) do
    parse_transaction_id_by_handle(transaction.handle.value)
    |> insert_or_update_transaction(transaction)
  end

  defp parse_transaction_id_by_handle(value) do
    KittenBlue.JWS.verify(value, [@key4transaction])
    |> case do
      {:ok, %{"handle" => @handle_type_transaction, "sub" => transaction_id}} -> transaction_id
      _ -> nil
    end
  end

  defp insert_or_update_transaction(transaction_id, transaction) do
    with display <- transaction.display |> Poison.encode!(),
         interact <- transaction.interact |> Poison.encode!(),
         user <- transaction.user |> Poison.encode!(),
         resources <- serialize_resources(transaction.resources),
         keys <- transaction.keys |> Poison.encode!() do
      %SampleTransaction{}
      |> SampleTransaction.changeset(%{
        id: transaction_id,
        status: transaction.status |> Atom.to_string(),
        display: display,
        interact: interact,
        user: user,
        resources: resources,
        keys: keys
      })
      |> Repo.insert_or_update()
      |> case do
        {:ok, _} ->
          :ok

        error ->
          Logger.warn("Save Sample Transaction failed: #{inspect(error)}")
          {:error, :internal_error}
      end
    end
  end

  defp serialize_resources(resources) when is_list(resources) do
    resources
    |> Enum.map(fn resource -> Poison.encode!(resource) end)
    |> Poison.encode!()
  end

  defp serialize_resources(resources) do
    resources |> Poison.encode!()
  end

  @spec get_transaction_by_handle(handle :: String.t()) ::
          Transaction.t() | {:error, :invalid_handle} | {:error, :invalid_transaction}
  def get_transaction_by_handle(handle) do
    # TODO: verify expiration
    with transaction_id when not is_nil(transaction_id) <- parse_transaction_id_by_handle(handle),
         sample_transaction = %SampleTransaction{} <- Repo.get!(SampleTransaction, transaction_id) do
      %Transaction{
        handle: Handle.new(%{value: handle, type: :bearer}),
        status: sample_transaction.status |> String.to_existing_atom(),
        display: sample_transaction.display |> Poison.decode!(as: %DisplayRequest{}),
        interact: sample_transaction.interact |> Poison.decode!(as: %Interact{}),
        user: sample_transaction.user |> Poison.decode!(as: %UserRequest{}),
        resources:
          sample_transaction.resources
          |> Poison.decode!()
          |> Enum.map(fn encoded_resource ->
            Poison.decode!(encoded_resource, as: %OAuthXYZ.Model.ResourceRequest{})
          end),
        keys: sample_transaction.keys |> Poison.decode!(as: %KeyRequest{})
      }
    else
      nil -> {:error, :invalid_handle}
      _ -> {:error, :invalid_transaction}
    end
  end

  @spec rotate_transaction_handle(transaction :: Transaction.t()) :: Transaction.t()
  def rotate_transaction_handle(transaction) do
    handle =
      parse_transaction_id_by_handle(transaction.handle.value)
      |> do_create_transaction_handle()

    Transaction.rotate_handle(transaction, handle)
  end

  @spec validate_transaction_request(request :: TransactionRequest.t()) ::
          TransactionRequest.t() | {:error, term}
  def validate_transaction_request(request) do
    cond do
      is_nil(request.resources) || is_nil(request.keys) || is_nil(request.interact) ->
        {:error, :invalid_request}

      true ->
        # TODO: more detail check(HTTP Header etc...)
        request
    end
  end

  @spec set_interact_response(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_response(transaction = %Transaction{interact: interact}) do
    if !is_nil(interact) && interact.can_redirect do
      interact_id = do_create_interact_id(transaction.handle.value)

      interaction_url = "http://localhost:4000/interact?interact_id=#{interact_id}"

      interact = %{interact | interact_id: interact_id}
      interact = %{interact | url: interaction_url}
      %{transaction | interact: interact}
    else
      transaction
    end
  end

  defp do_create_interact_id(handle_value) do
    transaction_id = parse_transaction_id_by_handle(handle_value)
    exp = System.system_time(:second) + @interact_id_expiration

    # TODO: other claims for resource access
    {:ok, token} =
      %{
        "iss" => @jwt_iss,
        "handle" => @handle_type_interact_id,
        "sub" => transaction_id,
        "exp" => exp
      }
      |> KittenBlue.JWS.sign(@key4transaction)

    token
  end

  @spec set_interact_server_nonce(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_server_nonce(transaction = %Transaction{interact: interact}) do
    if !is_nil(interact) && is_map(interact.callback) do
      server_nonce = Ulid.generate(System.system_time(:millisecond))
      interact = %{interact | server_nonce: server_nonce}
      %{transaction | interact: interact}
    else
      transaction
    end
  end

  @spec set_interact_user_code(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_user_code(transaction = %Transaction{interact: interact}) do
    if !is_nil(interact) && interact.can_user_code do
      user_code = :rand.uniform(100_000_000) |> Integer.to_string() |> String.pad_leading(8, "0")

      interact = %{interact | user_code: user_code}
      %{transaction | interact: interact}
    else
      transaction
    end
  end

  @spec set_wait_sec(transaction :: Transaction.t()) :: Transaction.t()
  def set_wait_sec(transaction), do: %{transaction | wait: @wait_sec}

  @spec create_or_update_access_token(transaction :: Transaction.t()) :: Transaction.t()
  def create_or_update_access_token(transaction) do
    with transaction_id when not is_nil(transaction_id) <-
           parse_transaction_id_by_handle(transaction.handle.value),
         access_token = do_create_access_token(transaction_id) do
      %{transaction | access_token: access_token}
    end
  end

  defp do_create_access_token(transaction_id) do
    iat = System.system_time(:second)

    # TODO: other claims for resource access
    {:ok, token} =
      %{
        "iss" => @jwt_iss,
        "handle" => @handle_type_access_token,
        "sub" => transaction_id,
        "iat" => iat
      }
      |> KittenBlue.JWS.sign(@key4transaction)

    Handle.new(%{value: token, type: :bearer})
  end
end
