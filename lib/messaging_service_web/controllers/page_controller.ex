defmodule MessagingServiceWeb.PageController do
  use MessagingServiceWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
