defmodule OAuthXYZ.Model.TransactionResponseTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.{Handle, Transaction, TransactionRequest, TransactionResponse}

  @request_params %{
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

  describe "new" do
    test "basic" do
      # init
      handle =
        Handle.new(%{value: Ulid.generate(System.system_time(:millisecond)), type: :bearer})

      transaction_request = TransactionRequest.parse(@request_params)
      transaction = Transaction.new(%{handle: handle, request: transaction_request})
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
    end

    test "interact" do
      # https://tools.ietf.org/id/draft-richer-transactional-authz-04.html#rfc.section.3
      handle = Handle.new(%{value: "80UPRY5NM33OMUKMKSKU", type: :bearer})
      transaction_request = TransactionRequest.parse(@request_params)
      transaction = Transaction.new(%{handle: handle, request: transaction_request})

      interact = transaction.interact
      interaction_url = "https://server.example.com/interact/4CF492MLVMSW9MKMXKHQ"
      interact = %{interact | url: interaction_url}
      server_nonce = "MBDOFXG4Y5CVJCX821LH"
      interact = %{interact | server_nonce: server_nonce}
      user_code_url = "https://server.example.com/interact/device"
      user_code = "A1BC-3DFF"
      interact = %{interact | user_code: %{url: user_code_url, code: user_code}}

      transaction = %{transaction | interact: interact}
      transaction_response = TransactionResponse.new(transaction)
      assert transaction_response.handle == handle
      assert transaction_response.interaction_url == interaction_url
      assert transaction_response.server_nonce == server_nonce
      assert transaction_response.user_code == %{url: user_code_url, code: user_code}
    end

    test "wait" do
      handle =
        Handle.new(%{value: Ulid.generate(System.system_time(:millisecond)), type: :bearer})

      transaction_request = TransactionRequest.parse(@request_params)
      transaction = Transaction.new(%{handle: handle, request: transaction_request})

      wait = 30
      transaction = %{transaction | wait: wait}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.wait == wait
    end

    test "token" do
      handle = Handle.new(%{value: "80UPRY5NM33OMUKMKSKU", type: :bearer})

      transaction_request = TransactionRequest.parse(@request_params)
      transaction = Transaction.new(%{handle: handle, request: transaction_request})

      access_token =
        Handle.new(%{value: "OS9M2PMHKUR64TB8N6BW7OZB8CDFONP219RP1LT0", type: :bearer})

      transaction = %{transaction | access_token: access_token}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.access_token == access_token
    end

    test "handles" do
      handle = Handle.new(%{value: "80UPRY5NM33OMUKMKSKU", type: :bearer})
      transaction_request = TransactionRequest.parse(@request_params)
      transaction = Transaction.new(%{handle: handle, request: transaction_request})

      # display
      display = transaction.display
      display_handle = Handle.new(%{value: "VBUEOIQA82PBY2ZDJW7Q", type: :bearer})
      display = %{display | handle: display_handle}

      transaction = %{transaction | display: display}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.display_handle == display_handle

      # TODO: handling resource handle
      # resources handle
      # resources_handle = Handle.new(%{value: "KLKP36N7GPOKRF3KGH5N", type: :bearer})

      # transaction = %{transaction | resources_handle: resources_handle}
      # transaction_response = TransactionResponse.new(transaction)

      # assert transaction_response.handle == handle
      # assert transaction_response.resources_handle == resources_handle

      # user handle
      user = transaction.user
      user_handle = Handle.new(%{value: "XUT2MFM1XBIKJKSDU8QM", type: :bearer})
      user = %{user | handle: user_handle}

      transaction = %{transaction | user: user}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.user_handle == user_handle

      # user handle
      user = transaction.user
      user_handle = Handle.new(%{value: "XUT2MFM1XBIKJKSDU8QM", type: :bearer})
      user = %{user | handle: user_handle}

      transaction = %{transaction | user: user}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.user_handle == user_handle

      # key handle
      keys = transaction.keys
      key_handle = Handle.new(%{value: "7C7C4AZ9KHRS6X63AJAO", type: :bearer})
      keys = %{keys | handle: key_handle}

      transaction = %{transaction | keys: keys}
      transaction_response = TransactionResponse.new(transaction)

      assert transaction_response.handle == handle
      assert transaction_response.key_handle == key_handle
    end
  end
end
