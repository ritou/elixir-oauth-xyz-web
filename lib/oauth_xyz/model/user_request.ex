defmodule OAuthXYZ.Model.UserRequest do
  @moduledoc """
  User Request Struct and Handling Functions.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,
    #! :string
    :assertion,
    #! :string
    :type
  ]

  @doc """
  Parse string or map and return structure
  """
  @spec parse(request :: map | String.t()) :: t
  def parse(handle) when is_binary(handle), do: %__MODULE__{handle: handle}

  def parse(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_assertion(request)
      |> parse_type(request)

    %__MODULE__{
      assertion: parsed_request.assertion,
      type: parsed_request.type
    }
  end

  # private

  defp parse_assertion(keys, %{"assertion" => assertion}),
    do: Map.put(keys, :assertion, assertion)

  defp parse_assertion(keys, _), do: Map.put(keys, :assertion, nil)

  defp parse_type(keys, %{"type" => type}), do: Map.put(keys, :type, type)
  defp parse_type(keys, _), do: Map.put(keys, :type, nil)
end
