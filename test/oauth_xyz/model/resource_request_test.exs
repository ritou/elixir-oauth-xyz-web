defmodule OAuthXYZ.Model.ResourceRequestTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.ResourceRequest

  test "constructor" do
    handle = "dolphin-metadata"

    [resource] = ResourceRequest.parse([handle])

    assert resource.handle == handle
    refute resource.actions
    refute resource.locations
    refute resource.datatypes

    actions = ["read", "write", "dolphin"]
    locations = ["https://server.example.net/", "https://resource.local/other"]
    datatypes = ["metadata", "images"]

    [resource] =
      ResourceRequest.parse([
        %{"actions" => actions, "locations" => locations, "datatypes" => datatypes}
      ])

    refute resource.handle
    assert resource.actions == actions
    assert resource.locations == locations
    assert resource.datatypes == datatypes

    [resource1, resource2] =
      ResourceRequest.parse([
        %{"actions" => actions, "locations" => locations, "datatypes" => datatypes},
        handle
      ])

    refute resource1.handle
    assert resource1.actions == actions
    assert resource1.locations == locations
    assert resource1.datatypes == datatypes

    assert resource2.handle == handle
    refute resource2.actions
    refute resource2.locations
    refute resource2.datatypes
  end
end
