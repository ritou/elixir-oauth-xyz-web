defmodule OAuthXYZWeb.Router do
  use OAuthXYZWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", OAuthXYZWeb do
    # Use the default browser stack
    pipe_through(:browser)

    # for top page
    get("/", PageController, :index)

    # for interaction
    get("/interact", InteractionController, :get_interaction)
    post("/interact/approve", InteractionController, :post_interaction_approve)

    # for device
    get("/interact/device", InteractionController, :get_interaction_device)
    post("/interact/device", InteractionController, :post_interaction_device)

    # for user signin session
    get("/signin", SessionController, :get_signin)
    post("/signin", SessionController, :post_signin)
    post("/signout", SessionController, :post_signout)
  end

  scope "/api", OAuthXYZWeb do
    pipe_through(:api)

    post("/transaction", TransactionController, :post_transaction)
  end
end
