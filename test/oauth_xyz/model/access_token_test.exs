defmodule OAuthXYZ.Model.AccessTokenTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.AccessToken

  test "constructor" do
    value = "VBUEOIQA82PBY2ZDJW7Q"

    access_token = AccessToken.new(%{value: value, type: :bearer})

    assert access_token.value == value
    assert access_token.type == :bearer

    access_token = AccessToken.new(%{value: value, type: :sha3})

    assert access_token.value == value
    assert access_token.type == :sha3
  end
end
