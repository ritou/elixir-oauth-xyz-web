defmodule OAuthXYZ.Model.AccessToken do
  @moduledoc """
  Access Token Model Module.
  """

  @type t :: %__MODULE__{}

  @token_types [:bearer, :sha3]

  # TODO: jwks support
  defstruct [
    #! :string
    :value,
    #! :atom
    :type
  ]

  @doc """
  Return Access Token Module
  """
  @spec new(data :: map) :: t
  def new(%{value: value, type: type}) when type in @token_types do
    %__MODULE__{
      value: value,
      type: type
    }
  end
end
