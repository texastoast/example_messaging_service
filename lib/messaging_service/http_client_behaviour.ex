defmodule MessagingService.HTTPClientBehaviour do
  @moduledoc """
  Behaviour for HTTP client operations.
  """

  @callback post(url :: String.t(), opts :: keyword()) :: {:ok, %Req.Response{}} | {:error, Exception.t()}
end
