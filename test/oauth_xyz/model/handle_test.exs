defmodule OAuthXYZ.Model.HandleTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.Handle

  test "constructor" do
    value = "VBUEOIQA82PBY2ZDJW7Q"

    handle = Handle.new(%{value: value, type: :bearer})

    assert handle.value == value
    assert handle.type == :bearer

    handle = Handle.new(%{value: value, type: :sha3})

    assert handle.value == value
    assert handle.type == :sha3
  end
end
