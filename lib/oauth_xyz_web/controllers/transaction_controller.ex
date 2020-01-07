defmodule OAuthXYZWeb.TransactionController do
  use OAuthXYZWeb, :controller

  alias OAuthXYZ.Service.Transaction, as: TransactionService
  alias OAuthXYZ.Model.{TransactionResponse, ErrorResponse}

  def post_transaction(conn, params) do
    TransactionService.process(params)
    |> case do
      {:ok, 200, response = %TransactionResponse{}} ->
        conn
        |> json(TransactionResponse.response(response))

      {:error, status, response = %ErrorResponse{}} ->
        # TODO: use fallback controller
        conn
        |> put_status(status)
        |> json(ErrorResponse.response(response))
    end
  end
end
