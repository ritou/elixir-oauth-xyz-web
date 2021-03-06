defmodule OAuthXYZ.Model.TransactionRequestTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.TransactionRequest

  test "constructor" do
    # init
    request = %{
      "resources" => [
        %{
          "actions" => [
            "read",
            "write",
            "dolphin"
          ],
          "locations" => [
            "https://server.example.net/",
            "https://resource.local/other"
          ],
          "datatypes" => [
            "metadata",
            "images"
          ]
        },
        "dolphin-metadata"
      ],
      "keys" => %{
        "proof" => "jwsd",
        "jwks" => %{
          "keys" => [
            %{
              "kty" => "RSA",
              "e" => "AQAB",
              "kid" => "xyz-1",
              "alg" => "RS256",
              "n" => "kOB5rR4Jv0GMeL...."
            }
          ]
        }
      },
      "interact" => %{
        "redirect" => true,
        "callback" => %{
          "uri" => "https://client.example.net/return/123455",
          "nonce" => "LKLTI25DK82FX4T4QFZC"
        }
      },
      "display" => %{
        "name" => "My Client Display Name",
        "uri" => "https://example.net/client"
      },
      "user" => %{
        "assertion" =>
          "eyJraWQiOiIxZTlnZGs3IiwiYWxnIjoiUlMyNTYifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg5NzYxMDAxIiwKICJhdWQiOiAiczZCaGRSa3F0MyIsCiAibm9uY2UiOiAibi0wUzZfV3pBMk1qIiwKICJleHAiOiAxMzExMjgxOTcwLAogImlhdCI6IDEzMTEyODA5NzAsCiAibmFtZSI6ICJKYW5lIERvZSIsCiAiZ2l2ZW5fbmFtZSI6ICJKYW5lIiwKICJmYW1pbHlfbmFtZSI6ICJEb2UiLAogImdlbmRlciI6ICJmZW1hbGUiLAogImJpcnRoZGF0ZSI6ICIwMDAwLTEwLTMxIiwKICJlbWFpbCI6ICJqYW5lZG9lQGV4YW1wbGUuY29tIiwKICJwaWN0dXJlIjogImh0dHA6Ly9leGFtcGxlLmNvbS9qYW5lZG9lL21lLmpwZyIKfQ.rHQjEmBqn9Jre0OLykYNnspA10Qql2rvx4FsD00jwlB0Sym4NzpgvPKsDjn_wMkHxcp6CilPcoKrWHcipR2iAjzLvDNAReF97zoJqq880ZD1bwY82JDauCXELVR9O6_B0w3K-E7yM2macAAgNCUwtik6SjoSUZRcf-O5lygIyLENx882p6MtmwaL1hd6qn5RZOQ0TLrOYu0532g9Exxcm-ChymrB4xLykpDj3lUivJt63eEGGN6DH5K6o33TcxkIjNrCD4XB1CKKumZvCedgHHF3IAK4dVEDSUoGlH9z4pP_eWYNXvqQOjGs-rDaQzUHl6cQQWNiDpWOl_lxXjQEvQ",
        "type" => "oidc_id_token"
      }
    }

    parsed_request = TransactionRequest.parse(request)

    assert parsed_request.resources
    assert parsed_request.keys
    assert parsed_request.interact
    assert parsed_request.display
    assert parsed_request.user
    refute parsed_request.handle
    refute parsed_request.interaction_ref

    # continue
    handle = "80UPRY5NM33OMUKMKSKU"

    interaction_ref =
      "CuD9MrpSXVKvvI6dN1awtNLx-HhZy46hJFDBicG4KoZaCmBofvqPxtm7CDMTsUFuvcmLwi_zUN70cCvalI6ENw"

    request = %{
      "handle" => handle,
      "interaction_ref" => interaction_ref
    }

    parsed_request = TransactionRequest.parse(request)

    assert parsed_request.handle == handle
    assert parsed_request.interaction_ref == interaction_ref
  end
end
