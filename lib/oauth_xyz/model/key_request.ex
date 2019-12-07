defmodule OAuthXYZ.Model.KeyRequest do
  @moduledoc """
  Key Request Struct and Handling Functions.

  ```
  # full?
  "keys": {
    "proof": "jwsd",
    "jwks": {
      "keys": [
        {
          "kty": "RSA",
          "e": "AQAB",
          "kid": "xyz-1",
          "alg": "RS256",
          "n": "kOB5rR4Jv0GMeLaY6_It_r3ORwdf8ci_JtffXyaSx8xY..."
        }
      ]
    },
    "cert": "MIIEHDCCAwSgAwIBAgIBATANBgkqhkiG9w0BAQsFA...",
    "did": "did:example:CV3BVVXK2PWWLCRQLRFU#xyz-1"
  }
  ```

  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,
    #! :map
    :jwks,
    #! :string
    :cert,
    #! :string
    :cert_256,
    #! :string
    :did,
    #! :string
    :proof
  ]

  @proof_list ["jwsd", "httpsig", "dpop", "pop", "mtls"]

  @doc """
  Parse string or map and return structure
  """
  @spec parse(request :: map | String.t()) :: t
  def parse(handle) when is_binary(handle), do: %__MODULE__{handle: handle}

  def parse(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_jwks(request)
      |> parse_cert(request)
      |> parse_cert_256(request)
      |> parse_did(request)
      |> parse_proof(request)

    %__MODULE__{
      jwks: parsed_request.jwks,
      cert: parsed_request.cert,
      cert_256: parsed_request.cert_256,
      did: parsed_request.did,
      proof: parsed_request.proof
    }
  end

  # private

  defp parse_jwks(keys, %{"jwks" => jwks}), do: Map.put(keys, :jwks, jwks)
  defp parse_jwks(keys, _), do: Map.put(keys, :jwks, nil)

  defp parse_cert(keys, %{"cert" => cert}), do: Map.put(keys, :cert, cert)
  defp parse_cert(keys, _), do: Map.put(keys, :cert, nil)

  defp parse_cert_256(keys, %{"cert#256" => cert_256}), do: Map.put(keys, :cert_256, cert_256)
  defp parse_cert_256(keys, _), do: Map.put(keys, :cert_256, nil)

  defp parse_did(keys, %{"did" => did}), do: Map.put(keys, :did, did)
  defp parse_did(keys, _), do: Map.put(keys, :did, nil)

  defp parse_proof(keys, %{"proof" => proof}) when proof in @proof_list,
    do: Map.put(keys, :proof, proof)

  # TODO : error handling
  defp parse_proof(keys, _), do: Map.put(keys, :proof, nil)
end
