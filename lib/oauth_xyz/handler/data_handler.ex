defmodule OAuthXYZ.Handler.DataHandler do
  @moduledoc """
  """

  alias OAuthXYZ.Model.{
    Handle,
    Transaction,
    TransactionRequest,
    DisplayRequest,
    UserRequest,
    ResourceRequest,
    KeyRequest
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
  @callback validate_and_set_display_handle(request :: TransactionRequest.t()) ::
              DisplayRequest.t() | {:error, :invalid_display}
  @callback validate_and_set_user_handle(request :: TransactionRequest.t()) ::
              UserRequest.t() | {:error, :invalid_user}
  @callback validate_and_set_resources_handle(request :: TransactionRequest.t()) ::
              [ResourceRequest.t()] | {:error, :invalid_resources}
  @callback validate_and_set_keys_handle(request :: TransactionRequest.t()) ::
              KeyRequest.t() | {:error, :invalid_keys}
  @callback validate_interact_request(request :: TransactionRequest.t()) ::
              :ok | {:error, :invalid_interact}

  ## get by handle
  @callback get_display_by_handle(handle :: String.t()) ::
              DisplayRequest.t() | {:error, :invalid_display}
  @callback get_user_by_handle(handle :: String.t()) :: UserRequest.t() | {:error, :invalid_user}
  @callback get_resources_by_handle(handle :: String.t()) ::
              ResourceRequest.t() | {:error, :invalid_resources}
  @callback get_keys_by_handle(handle :: String.t()) :: KeyRequest.t() | {:error, :invalid_keys}

  # set interact id and interaction url
  @callback set_interact_response(transaction :: Transaction.t()) :: Transaction.t()
  @callback set_interact_server_nonce(transaction :: Transaction.t()) :: Transaction.t()
  @callback set_interact_user_code(transaction :: Transaction.t()) :: Transaction.t()

  # set wait sec for wait status
  @callback set_wait_sec(transaction :: Transaction.t()) :: Transaction.t()

  # for access token
  @callback create_or_update_access_token(transaction :: Transaction.t()) :: Transaction.t()
end
