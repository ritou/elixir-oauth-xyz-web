defmodule OAuthXYZ.Model.KeyRequest do
  @moduledoc """
  Key Request Struct and Handling Functions.
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :string
    :handle,
    #! :map
    :jwk,
    #! :string
    :cert,
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
      |> parse_jwk(request)
      |> parse_cert(request)
      |> parse_did(request)
      |> parse_proof(request)

    %__MODULE__{
      jwk: parsed_request.jwk,
      cert: parsed_request.cert,
      did: parsed_request.did,
      proof: parsed_request.proof
    }
  end

  # private

  defp parse_jwk(keys, %{"jwks" => jwks}), do: Map.put(keys, :jwk, jwks)
  defp parse_jwk(keys, _), do: Map.put(keys, :jwk, nil)

  defp parse_cert(keys, %{"cert" => cert}), do: Map.put(keys, :cert, cert)
  defp parse_cert(keys, _), do: Map.put(keys, :cert, nil)

  defp parse_did(keys, %{"did" => did}), do: Map.put(keys, :did, did)
  defp parse_did(keys, _), do: Map.put(keys, :did, nil)

  defp parse_proof(keys, %{"proof" => proof}) when proof in @proof_list,
    do: Map.put(keys, :proof, proof)

  # TODO : error handling
  defp parse_proof(keys, _), do: Map.put(keys, :proof, nil)
end
