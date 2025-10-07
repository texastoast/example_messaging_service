defmodule MessagingService.Providers.Behaviour do
  @moduledoc """
  Defines the callbacks to be implemented by any messaging provider.
  """

  @doc """
  Sends a message to the provider.
  """
  @callback send_message(message :: map()) :: {:ok, map()} | {:error, map()}

  @doc """
  Receives a message from the provider.
  """
  @callback receive_message(message :: map()) :: {:ok, map()} | {:error, map()}
end
