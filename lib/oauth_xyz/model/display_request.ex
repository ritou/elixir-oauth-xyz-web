defmodule OAuthXYZ.Model.DisplayRequest do
  @moduledoc """
  Display Request Struct and Handling Functions.
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

  @doc """
  Parse string or map and return structure
  """
  @spec parse(request :: map | String.t()) :: t
  def parse(handle) when is_binary(handle), do: %__MODULE__{handle: handle}

  def parse(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_name(request)
      |> parse_uri(request)
      |> parse_logo_uri(request)

    %__MODULE__{
      name: parsed_request.name,
      uri: parsed_request.uri,
      logo_uri: parsed_request.logo_uri
    }
  end

  # private

  defp parse_name(keys, %{"name" => name}), do: Map.put(keys, :name, name)
  defp parse_name(keys, _), do: Map.put(keys, :name, nil)

  defp parse_uri(keys, %{"uri" => uri}), do: Map.put(keys, :uri, uri |> to_uri)
  defp parse_uri(keys, _), do: Map.put(keys, :uri, nil)

  defp parse_logo_uri(keys, %{"logo_uri" => logo_uri}),
    do: Map.put(keys, :logo_uri, logo_uri |> to_uri)

  defp parse_logo_uri(keys, _), do: Map.put(keys, :logo_uri, nil)

  defp to_uri(uri) do
    case URI.parse(uri) do
      %URI{scheme: nil} -> nil
      %URI{host: nil, path: nil} -> nil
      _ -> uri
    end
  end
end
