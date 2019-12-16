defmodule OAuthXYZ.Model.ErrorResponseTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.ErrorResponse

  @valid_reason_list ErrorResponse.__reason_list__()

  describe "new" do
    test "valid" do
      for reason <- @valid_reason_list do
        error_response = ErrorResponse.new(reason)
        assert error_response.error == reason
      end
    end
  end
end
