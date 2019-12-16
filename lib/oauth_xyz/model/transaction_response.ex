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
    :key_handle,
    #! :string
    :resources_handle
  ]

  def new(transaction = %Transaction{}) do
    %__MODULE__{
      interaction_url: transaction.interact.url,
      server_nonce: transaction.interact.server_nonce,
      user_code: transaction.interact.user_code,
      wait: transaction.wait,
      access_token: transaction.access_token,
      handle: transaction.handle,
      display_handle: transaction.display.handle,
      user_handle: transaction.user.handle,
      key_handle: transaction.keys.handle,
      resources_handle: transaction.resources_handle
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
