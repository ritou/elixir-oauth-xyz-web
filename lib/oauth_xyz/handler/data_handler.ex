defmodule OAuthXYZ.Handler.DataHandler do
  @moduledoc """
  """

  alias OAuthXYZ.Model.{
    Handle,
    Transaction,
    TransactionRequest
  }

  # transaction handle
  @callback create_transaction_handle() :: Handle.t()
  # save transaction data
  @callback save_transaction(transaction :: Transaction.t()) :: :ok | {:error, :internal_error}
  # lookup by transaction handle
  @callback get_transaction_by_handle(handle :: String.t()) ::
              Transaction.t() | {:error, :invalid_handle} | {:error, :invalid_transaction}
  # rotate transaction handle
  @callback rotate_transaction_handle(transaction :: Transaction.t()) :: Transaction.t()

  # request and handles
  # validate request and set handle
  @callback validate_transaction_request(request :: TransactionRequest.t()) ::
              TransactionRequest.t() | {:error, term}

  # set interact id and interaction url
  @callback set_interact_response(transaction :: Transaction.t()) :: Transaction.t()
  # set interact server_nonce
  @callback set_interact_server_nonce(transaction :: Transaction.t()) :: Transaction.t()
  @callback set_interact_user_code(transaction :: Transaction.t()) :: Transaction.t()

  # set wait sec for wait status
  @callback set_wait_sec(transaction :: Transaction.t()) :: Transaction.t()

  # for access token
  @callback create_or_update_access_token(transaction :: Transaction.t()) :: Transaction.t()
end
