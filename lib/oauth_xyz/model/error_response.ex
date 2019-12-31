defmodule OAuthXYZ.Model.ErrorResponse do
  @moduledoc """
  Error Response Handling Module.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :atom
    :error
  ]

  # https://tools.ietf.org/id/draft-richer-transactional-authz-04.html#rfc.section.6
  @spec_defined_reason_list [:user_denied, :too_fast, :unknown_transaction, :unknown_handle]

  # basic error response
  @reason_list @spec_defined_reason_list ++
                 [
                   :invalid_request,
                   :internal_error,
                   :invalid_display,
                   :invalid_user,
                   :invalid_resources,
                   :invalid_keys,
                   :invalid_interact
                 ]

  def __reason_list__, do: @reason_list

  def new(reason) when reason in @reason_list do
    %__MODULE__{
      error: reason
    }
  end

  def new(reason) when reason in @reason_list do
    %__MODULE__{
      error: reason
    }
  end

  def response(response = %__MODULE__{}) do
    Map.from_struct(response)
  end
end
