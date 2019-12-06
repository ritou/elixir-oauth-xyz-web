defmodule OAuthXYZ.Model.DisplayRequestTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.DisplayRequest

  test "constructor" do
    handle = "VBUEOIQA82PBY2ZDJW7Q"

    display = DisplayRequest.parse(handle)

    assert display.handle == handle
    refute display.name
    refute display.uri
    refute display.logo_uri

    name = "My Client Display Name"
    uri = "https://example.net/client"
    logo_uri = "https://example.net/client/logo"

    display =
      DisplayRequest.parse(%{
        "name" => name,
        "uri" => uri,
        "logo_uri" => logo_uri
      })

    assert display.name == name
    assert display.uri == uri
    assert display.logo_uri == logo_uri
    refute display.handle
  end
end
