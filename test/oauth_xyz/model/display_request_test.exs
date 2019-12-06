defmodule OAuthXYZ.Model.DisplayRequestTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.DisplayRequest

  test "constructor" do
    display = %DisplayRequest{
      handle: "12345",
      name: "ritou",
      uri: "https://example.com",
      logo_uri: "https://example.com/logo"
    }

    assert display.handle
    assert display.name
    assert display.uri
    assert display.logo_uri
  end
end
