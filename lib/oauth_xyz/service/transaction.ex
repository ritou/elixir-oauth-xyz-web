defmodule OAuthXYZ.Service.Transaction do
  @moduledoc """
  Service for Transaction Endpoint.


  The controller of your WebApplication can implement Transaction Endpoint of OAuth XYZ by using this Module.

  To use this module, you have to add your DataHandler module to config.

  ```
  config :oauth_xyz, OAuthXYZ.Service.Transaction,
    data_handler: YourDataHandler
  ```

  Your DataHandler module must use OAuthXYZ.Handler.DataHandler as a behaviour.

  ```
  defmodule YourDataHandler do
    @behaviour OAuthXYZ.Handler.DataHandler

    ...
  ```

  Refer to the OAuthXYZ.Handler.DataHandler's document for details.
  """

  alias OAuthXYZ.Model.{
    Transaction,
    TransactionRequest,
    TransactionResponse,
    ErrorResponse,
    DisplayRequest,
    UserRequest,
    ResourceRequest,
    KeyRequest
  }

  @data_handler Application.fetch_env!(:oauth_xyz, __MODULE__)
                |> Keyword.fetch!(:data_handler)

  @spec process(request_params :: map) ::
          {:ok, http_status :: integer, response :: TransactionResponse.t()}
          | {:error, http_status :: integer, response :: ErrorResponse.t()}
  def process(request_params) when is_map(request_params) do
    with transaction_request = %TransactionRequest{} <- TransactionRequest.parse(request_params),
         transaction <- get_transaction(transaction_request),
         transaction_response = %TransactionResponse{} <- do_process(transaction) do
      {:ok, 200, transaction_response}
    end
  end

  def process(_), do: {:error, 400, ErrorResponse.new(:invalid_request)}

  # private

  defp get_transaction(transaction_request = %TransactionRequest{handle: nil}) do
    with transaction_request = %TransactionRequest{} <-
           validate_transaction_request(transaction_request),
         transaction_handle <- @data_handler.create_transaction_handle(),
         transaction <-
           Transaction.new(%{handle: transaction_handle, request: transaction_request}) do
      transaction
    else
      {:error, response = %ErrorResponse{}} -> {:error, 400, response}
      # TODO: error logging
      _ -> {:error, 500, ErrorResponse.new(:inetrnal_error)}
    end
  end

  defp get_transaction(%TransactionRequest{handle: handle}) do
    @data_handler.get_transaction_by_handle(handle)
    |> case do
      transaction = %Transaction{} -> transaction
      {:error, error} -> {:error, 400, ErrorResponse.new(error)}
      # TODO: error logging
      _ -> {:error, 500, ErrorResponse.new(:inetrnal_error)}
    end
  end

  defp validate_transaction_request(transaction_request) do
    with display = %DisplayRequest{} <- validate_display_request(transaction_request),
         user = %UserRequest{} <- validate_user_request(transaction_request),
         resources when is_list(resources) <- validate_resources_request(transaction_request),
         keys = %KeyRequest{} <- validate_keys_request(transaction_request),
         :ok <-
           @data_handler.validate_interact_request(transaction_request) do
      %TransactionRequest{
        resources: resources,
        keys: keys,
        interact: transaction_request.interact,
        display: display,
        user: user
      }
    end
  end

  defp validate_display_request(
         transaction_request = %TransactionRequest{display: %DisplayRequest{handle: nil}}
       ),
       do: @data_handler.validate_and_set_display_handle(transaction_request)

  defp validate_display_request(%TransactionRequest{display: %DisplayRequest{handle: handle}}),
    do: @data_handler.get_display_by_handle(handle)

  defp validate_user_request(
         transaction_request = %TransactionRequest{user: %UserRequest{handle: nil}}
       ),
       do: @data_handler.validate_and_set_user_handle(transaction_request)

  defp validate_user_request(%TransactionRequest{user: %UserRequest{handle: handle}}),
    do: @data_handler.get_user_by_handle(handle)

  defp validate_resources_request(
         transaction_request = %TransactionRequest{resources: %ResourceRequest{handle: nil}}
       ),
       do: @data_handler.validate_and_set_resources_handle(transaction_request)

  defp validate_resources_request(%TransactionRequest{resources: %ResourceRequest{handle: handle}}),
       do: @data_handler.get_resources_by_handle(handle)

  defp validate_keys_request(
         transaction_request = %TransactionRequest{keys: %DisplayRequest{handle: nil}}
       ),
       do: @data_handler.validate_and_set_keys_handle(transaction_request)

  defp validate_keys_request(%TransactionRequest{keys: %DisplayRequest{handle: handle}}),
    do: @data_handler.get_keys_by_handle(handle)

  # process transaction and response

  defp set_interact_response(transaction = %Transaction{}) do
    if !is_nil(transaction.interact) && !is_nil(transaction.interact.redirect) do
      @data_handler.set_interact_response(transaction)
    else
      transaction
    end
  end

  defp set_interact_server_nonce(transaction = %Transaction{}) do
    if !is_nil(transaction.interact) && !is_nil(transaction.interact.callback) do
      @data_handler.set_interact_server_nonce(transaction)
    else
      transaction
    end
  end

  defp set_interact_user_code(transaction = %Transaction{}) do
    if !is_nil(transaction.interact) && !is_nil(transaction.interact.callback) do
      @data_handler.set_interact_user_code(transaction)
    else
      transaction
    end
  end

  defp do_process(transaction = %Transaction{status: :new}) do
    with transaction <- set_interact_response(transaction),
         transaction <- set_interact_server_nonce(transaction),
         transaction <- set_interact_user_code(transaction),
         transaction <- Transaction.update_status(transaction, :wait),
         transaction <- @data_handler.set_wait_sec(transaction),
         :ok <- @data_handler.save_transaction(transaction) do
      TransactionResponse.new(transaction)
    end
  end

  defp do_process(transaction = %Transaction{status: :authorized}) do
    with transaction <- @data_handler.create_or_update_access_token(transaction),
         transaction <- Transaction.update_status(transaction, :issued),
         :ok <-
           @data_handler.save_transaction(transaction) do
      TransactionResponse.new(transaction)
    end
  end

  defp do_process(transaction = %Transaction{status: :issued}) do
    with transaction <- @data_handler.rotate_transaction_handle(transaction),
         transaction <- @data_handler.create_or_update_access_token(transaction),
         :ok <- @data_handler.save_transaction(transaction) do
      TransactionResponse.new(transaction)
    end
  end

  defp do_process(transaction = %Transaction{status: :wait, wait: wait_sec})
       when not is_nil(wait_sec) do
    TransactionResponse.new(transaction)
  end

  defp do_process(%Transaction{status: :denied}) do
    {:error, 403, ErrorResponse.new(:inetrnal_error)}
  end

  defp do_process(_) do
    {:error, 500, ErrorResponse.new(:inetrnal_error)}
  end
end
