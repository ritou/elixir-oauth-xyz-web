defmodule OAuthXYZWeb.PageController do
  use OAuthXYZWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
