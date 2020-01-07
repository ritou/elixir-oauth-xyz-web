defmodule OAuthXYZ.Model.TransactionResponse do
  @moduledoc """
  Response Handling Module.


  """

  alias OAuthXYZ.Model.Transaction

  @type t :: %__MODULE__{}

  defstruct [
    # Next Step: Redirect
    #! :string
    :interaction_url,
    #! :string
    :server_nonce,

    # Next Step: Device
    #! :map
    :user_code,

    # Next Step: Wait
    #! :integer
    :wait,

    # Next Step: Token
    #! OAuthXYZ.Model.Handle
    :access_token,

    # Handles
    #! :string
    :handle,
    #! :string
    :display_handle,
    #! :string
    :user_handle,
    #! :string
    :key_handle
    #! :string
    # :resources_handle
  ]

  def new(transaction = %Transaction{}) do
    %__MODULE__{
      interaction_url:
        if transaction.interact do
          transaction.interact.url
        else
          nil
        end,
      server_nonce:
        if transaction.interact do
          transaction.interact.server_nonce
        else
          nil
        end,
      user_code:
        if transaction.interact do
          transaction.interact.user_code
        else
          nil
        end,
      wait: transaction.wait,
      access_token: transaction.access_token,
      handle: transaction.handle,
      display_handle:
        if transaction.display do
          transaction.display.handle
        else
          nil
        end,
      user_handle:
        if transaction.user do
          transaction.user.handle
        else
          nil
        end,
      key_handle:
        if transaction.keys do
          transaction.keys.handle
        else
          nil
        end
      # TODO : handling resource handle 
      # resources_handle: transaction.resources_handle
    }
  end

  def response(response = %__MODULE__{}) do
    Map.from_struct(response)
    |> compact()
  end

  defp compact(map) do
    for {k, v} <- map, v != nil, into: %{}, do: {k, v}
  end
end
