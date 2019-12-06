defmodule OAuthXYZ.Model.DisplayRequest do
  @moduledoc """
  Display Request Struct and Handling Function.
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
