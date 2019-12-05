defmodule OAuthXYZ.Model.DisplayRequest do
  @moduledoc """
  Display Request Handling Module.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,

    #! :string
    :name,

    #! :string
    :uri,

    #! :string
    :logo_uri
  ]
end
