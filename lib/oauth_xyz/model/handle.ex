defmodule OAuthXYZ.Model.Handle do
  @moduledoc """
  Handle model.
  """

  @type t :: %__MODULE__{}

  @token_types [:bearer, :sha3]

  defstruct [
    #! :string
    :value,
    #! :atom
    :type
  ]

  @doc """
  Return Handle Module
  """
  @spec new(data :: map) :: t
  def new(%{value: value, type: type}) when type in @token_types do
    %__MODULE__{
      value: value,
      type: type
    }
  end
end
