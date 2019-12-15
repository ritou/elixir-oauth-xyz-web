defmodule OAuthXYZ.Model.TransactionRequest do
  @moduledoc """
  Request Handling Module.

  ```
  # Transaction request
  {
    "resources": [
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
    ],
    "keys": {
        "proof": "jwsd",
        "jwks": {
            "keys": [
                {
                    "kty": "RSA",
                    "e": "AQAB",
                    "kid": "xyz-1",
                    "alg": "RS256",
                    "n": "kOB5rR4Jv0GMeL...."
                }
            ]
        }
    },
    "interact": {
        "redirect": true,
        "callback": {
            "uri": "https://client.example.net/return/123455",
            "nonce": "LKLTI25DK82FX4T4QFZC"
        }
    },
    "display": {
        "name": "My Client Display Name",
        "uri": "https://example.net/client"
    }
  }

  # Transaction continue request
  {
    "handle": "tghji76ytghj9876tghjko987yh"
  }
  ```
  """

  alias OAuthXYZ.Model.{ResourceRequest, KeyRequest, Interact, DisplayRequest, UserRequest}

  @type t :: %__MODULE__{}

  # TODO: additional params
  defstruct [
    #! %OAuthXYZ.Model.ResourceRequest{}
    :resources,
    #! %OAuthXYZ.Model.KeyRequest{}
    :keys,
    #! %OAuthXYZ.Model.Interact{}
    :interact,
    #! %OAuthXYZ.Model.DisplayRequest{}
    :display,
    #! %OAuthXYZ.Model.UserRequest{}
    :user,
    #! :string
    :handle,
    #! :string
    :interaction_ref
  ]

  def parse(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_resources(request)
      |> parse_keys(request)
      |> parse_interact(request)
      |> parse_display(request)
      |> parse_user(request)
      |> parse_handle(request)
      |> parse_interaction_ref(request)

    %__MODULE__{
      resources: parsed_request.resources,
      keys: parsed_request.keys,
      interact: parsed_request.interact,
      display: parsed_request.display,
      user: parsed_request.user,
      handle: parsed_request.handle,
      interaction_ref: parsed_request.interaction_ref
    }
  end

  # private

  defp parse_resources(keys, %{"resources" => resources}),
    do: Map.put(keys, :resources, ResourceRequest.parse(resources))

  defp parse_resources(keys, _), do: Map.put(keys, :resources, nil)

  defp parse_keys(keys, %{"keys" => keys_param}),
    do: Map.put(keys, :keys, KeyRequest.parse(keys_param))

  defp parse_keys(keys, _), do: Map.put(keys, :keys, nil)

  defp parse_interact(keys, %{"interact" => interact}),
    do: Map.put(keys, :interact, Interact.parse(interact))

  defp parse_interact(keys, _), do: Map.put(keys, :interact, nil)

  defp parse_display(keys, %{"display" => display}),
    do: Map.put(keys, :display, DisplayRequest.parse(display))

  defp parse_display(keys, _), do: Map.put(keys, :display, nil)

  defp parse_user(keys, %{"user" => user}), do: Map.put(keys, :user, UserRequest.parse(user))

  defp parse_user(keys, _), do: Map.put(keys, :user, nil)

  defp parse_handle(keys, %{"handle" => handle}), do: Map.put(keys, :handle, handle)

  defp parse_handle(keys, _), do: Map.put(keys, :handle, nil)

  defp parse_interaction_ref(keys, %{"interaction_ref" => interaction_ref}),
    do: Map.put(keys, :interaction_ref, interaction_ref)

  defp parse_interaction_ref(keys, _), do: Map.put(keys, :interaction_ref, nil)
end
