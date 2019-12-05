defmodule OAuthXYZ.Model.TransactionRequest do
  @moduledoc """
  Request Handling Module.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,

    #! :string
    :interact_handle,

    #! %OAuthXYZ.Model.DisplayRequest{}
    :display,

    #! %OAuthXYZ.Model.InteractRequest{}
    :interact,

    #! %OAuthXYZ.Model.ResourceRequest{}
    :resource,

    #! %OAuthXYZ.Model.KeyRequest{}
    :keys
  ]
end
