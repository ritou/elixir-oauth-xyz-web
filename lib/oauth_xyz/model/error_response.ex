defmodule OAuthXYZ.Model.ErrorResponse do
  @moduledoc """
  Error Response Handling Module.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :atom
    :error
  ]

  @reason_list [:user_denied, :too_fast, :unknown_transaction, :unknown_handle]
  def __reason_list__, do: @reason_list

  def new(reason) when reason in @reason_list do
    %__MODULE__{
      error: reason
    }
  end

  def response(response = %__MODULE__{}) do
    Map.from_struct(response)
  end
end
