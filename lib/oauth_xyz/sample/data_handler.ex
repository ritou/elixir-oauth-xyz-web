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
      repo =
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
        keys: sample_transaction.keys |> Poison.decode!(as: %KeyRequest{}),
        wait: @wait_sec
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
end
