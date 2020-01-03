defmodule OAuthXYZ.Sample.DataHandler do
  @behaviour OAuthXYZ.Handler.DataHandler

  require Logger

  alias OAuthXYZ.Model.{
    Handle,
    Transaction,
    DisplayRequest,
    Interact,
    UserRequest,
    ResourceRequest,
    KeyRequest
  }

  alias OAuthXYZ.Repo
  alias OAuthXYZ.Sample.Model.Transaction, as: SampleTransaction

  @key4transaction Application.fetch_env!(:oauth_xyz, __MODULE__)
                   |> Keyword.fetch!(:key4transaction)
                   |> KittenBlue.JWK.from_compact()

  @handle_type_transaction "tx"

  @handle_type_access_token "at"

  @wait_sec 30

  @spec create_transaction_handle() :: Handle.t()
  def create_transaction_handle() do
    Ulid.generate(System.system_time(:millisecond))
    |> do_create_transaction_handle()
  end

  defp do_create_transaction_handle(transaction_id) do
    iat = System.system_time(:second)

    {:ok, token} =
      %{"handle" => @handle_type_transaction, "sub" => transaction_id, "iat" => iat}
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
         resources <-
           transaction.resources
           |> Enum.map(fn resource -> Poison.encode!(resource) end)
           |> Poison.encode!(),
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

  @spec validate_and_set_display_handle(request :: TransactionRequest.t()) ::
          DisplayRequest.t() | {:error, :invalid_display}
  def validate_and_set_display_handle(request) do
    # TODO: do validation
    request.display
  end

  @spec validate_and_set_user_handle(request :: TransactionRequest.t()) ::
          UserRequest.t() | {:error, :invalid_user}
  def validate_and_set_user_handle(request) do
    # TODO: do validation
    request.user
  end

  @spec validate_and_set_resources_handle(request :: TransactionRequest.t()) ::
          [ResourceRequest.t()] | {:error, :invalid_resources}
  def validate_and_set_resources_handle(request) do
    # TODO: do validation
    request.resources
  end

  @spec validate_and_set_keys_handle(request :: TransactionRequest.t()) ::
          KeyRequest.t() | {:error, :invalid_keys}
  def validate_and_set_keys_handle(request) do
    # TODO: do validation
    request.keys
  end

  @spec validate_interact_request(request :: TransactionRequest.t()) ::
          :ok | {:error, :invalid_interact}
  def validate_interact_request(_request) do
    # TODO: do validation
    :ok
  end

  @spec get_display_by_handle(handle :: String.t()) ::
          DisplayRequest.t() | {:error, :invalid_display}
  def get_display_by_handle(_handle) do
    {:error, :invalid_display}
  end

  @spec get_user_by_handle(handle :: String.t()) :: UserRequest.t() | {:error, :invalid_user}
  def get_user_by_handle(_handle) do
    {:error, :invalid_user}
  end

  @spec get_resources_by_handle(handle :: String.t()) ::
          ResourceRequest.t() | {:error, :invalid_resources}
  def get_resources_by_handle(_handle) do
    {:error, :invalid_resources}
  end

  @spec get_keys_by_handle(handle :: String.t()) :: KeyRequest.t() | {:error, :invalid_keys}
  def get_keys_by_handle(_handle) do
    {:error, :invalid_keys}
  end

  @spec set_interact_response(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_response(transaction) do
    transaction
  end

  @spec set_interact_server_nonce(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_server_nonce(transaction) do
    transaction
  end

  @spec set_interact_user_code(transaction :: Transaction.t()) :: Transaction.t()
  def set_interact_user_code(transaction) do
    transaction
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

    {:ok, token} =
      %{"handle" => @handle_type_access_token, "sub" => transaction_id, "iat" => iat}
      |> KittenBlue.JWS.sign(@key4transaction)

    Handle.new(%{value: token, type: :bearer})
  end
end
