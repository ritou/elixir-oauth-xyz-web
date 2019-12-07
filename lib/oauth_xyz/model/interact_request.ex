defmodule OAuthXYZ.Model.InteractRequest do
  @moduledoc """
  Interact Request Handling Module.

  ```
  # redirect
  {
    "redirect": true,
    "callback": {
      "uri": "https://client.example.net/return/123455",
      "nonce": "LKLTI25DK82FX4T4QFZC"
    }
  }

  # device
  {
    "user_code": true
  }

  # QR code
  {
    "redirect": true,
    "user_code": true
  }

  # DIDComm
  {
    "didcomm": true
  }

  # DIDComm Query
  {
    "didcomm_query": true
  }

  ```
  """

  @type t :: %__MODULE__{}

  defstruct [
    #! :boolean
    :redirect,
    #! :map
    :callback,
    #! :boolean
    :user_code,
    #! :boolean
    :didcomm,
    #! :boolean
    :didcomm_query
  ]

  @doc """
  Parse map and return structure
  """
  @spec parse(request :: map) :: t
  def parse(request) when is_map(request) do
    parsed_request =
      %{}
      |> parse_redirect(request)
      |> parse_callback(request)
      |> parse_user_code(request)
      |> parse_didcomm(request)
      |> parse_didcomm_query(request)

    %__MODULE__{
      redirect: parsed_request.redirect,
      callback: parsed_request.callback,
      user_code: parsed_request.user_code,
      didcomm: parsed_request.didcomm,
      didcomm_query: parsed_request.didcomm_query
    }
  end

  # private

  defp parse_redirect(keys, %{"redirect" => redirect}), do: Map.put(keys, :redirect, redirect)
  defp parse_redirect(keys, _), do: Map.put(keys, :redirect, nil)

  defp parse_callback(keys, %{"callback" => callback}),
    do: Map.put(keys, :callback, callback |> parse_callback_map())

  defp parse_callback(keys, _), do: Map.put(keys, :callback, nil)

  # TODO: more strict check
  defp parse_callback_map(%{"uri" => _uri, "nonce" => _nonce} = callback), do: callback
  defp parse_callback_map(_), do: nil

  defp parse_user_code(keys, %{"user_code" => user_code}),
    do: Map.put(keys, :user_code, user_code)

  defp parse_user_code(keys, _), do: Map.put(keys, :user_code, nil)

  defp parse_didcomm(keys, %{"didcomm" => didcomm}), do: Map.put(keys, :didcomm, didcomm)
  defp parse_didcomm(keys, _), do: Map.put(keys, :didcomm, nil)

  defp parse_didcomm_query(keys, %{"didcomm_query" => didcomm_query}),
    do: Map.put(keys, :didcomm_query, didcomm_query)

  defp parse_didcomm_query(keys, _), do: Map.put(keys, :didcomm_query, nil)
end
