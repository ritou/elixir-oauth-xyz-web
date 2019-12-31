defmodule OAuthXYZ.Model.InteractTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.Interact

  test "constructor" do
    uri = "https://client.example.net/return/123455"
    nonce = "LKLTI25DK82FX4T4QFZC"

    interact =
      Interact.parse(%{
        "redirect" => true,
        "callback" => %{
          "uri" => uri,
          "nonce" => nonce
        }
      })

    assert interact.can_redirect

    assert interact.callback == %{
             "uri" => uri,
             "nonce" => nonce
           }

    refute interact.can_user_code
    refute interact.didcomm
    refute interact.didcomm_query

    interact =
      Interact.parse(%{
        "user_code" => true
      })

    refute interact.can_redirect
    refute interact.callback
    assert interact.can_user_code == true
    refute interact.didcomm
    refute interact.didcomm_query

    interact =
      Interact.parse(%{
        "didcomm" => true
      })

    refute interact.can_redirect
    refute interact.callback
    refute interact.can_user_code
    assert interact.didcomm == true
    refute interact.didcomm_query

    interact =
      Interact.parse(%{
        "didcomm_query" => true
      })

    refute interact.can_redirect
    refute interact.callback
    refute interact.can_user_code
    refute interact.didcomm
    assert interact.didcomm_query == true
  end
end
