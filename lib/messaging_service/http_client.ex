defmodule MessagingService.HTTPClient do
  @moduledoc """
  Real HTTP client implementation using Req.
  """

  @behaviour MessagingService.HTTPClientBehaviour

  @impl MessagingService.HTTPClientBehaviour
  def post(url, opts) do
    Req.post(url, opts)
  end
end
