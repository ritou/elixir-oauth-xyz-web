defmodule OAuthXYZ.Model.ResourceRequest do
  @moduledoc """
  Resource Request Handling Module.

  ```
  # Resources
  [
    {
      "actions": [
        "read",
        "write",
        "dolphin"
      ],
      "locations": [
        "https://server.example.net/",
        "https://resource.local/other"
      ],
      "datatypes": [
        "metadata",
        "images"
      ]
    },
    "dolphin-metadata"
  ]

  # Resource

  ## handle
  "dolphin-metadata"

  ## object
  {
    "actions": [
      "read",
      "write",
      "dolphin"
    ],
    "locations": [
      "https://server.example.net/",
      "https://resource.local/other"
    ],
    "datatypes": [
      "metadata",
      "images"
    ]
  }
  ```
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,
    #! :list
    :actions,
    #! :list
    :locations,
    #! :list
    :datatypes
  ]

  @doc """
  Parse each resource and return structure list
  """
  @spec parse([request :: map | String.t()]) :: [t]
  def parse(resource_list) when is_list(resource_list),
    do: Enum.map(resource_list, fn resource -> parse_resource(resource) end)

  @doc """
  Parse string or map and return structure
  """
  @spec parse_resource(request :: map | String.t()) :: t
  def parse_resource(handle) when is_binary(handle), do: %__MODULE__{handle: handle}

  def parse_resource(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_actions(request)
      |> parse_locations(request)
      |> parse_datatypes(request)

    %__MODULE__{
      actions: parsed_request.actions,
      locations: parsed_request.locations,
      datatypes: parsed_request.datatypes
    }
  end

  # private

  defp parse_actions(keys, %{"actions" => actions}), do: Map.put(keys, :actions, actions)
  defp parse_actions(keys, _), do: Map.put(keys, :actions, nil)

  defp parse_locations(keys, %{"locations" => locations}),
    do: Map.put(keys, :locations, locations)

  defp parse_locations(keys, _), do: Map.put(keys, :locations, nil)

  defp parse_datatypes(keys, %{"datatypes" => datatypes}),
    do: Map.put(keys, :datatypes, datatypes)

  defp parse_datatypes(keys, _), do: Map.put(keys, :datatypes, nil)
end
