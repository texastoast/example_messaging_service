defmodule MessagingService.Providers.Behaviour do
  @moduledoc """
  Defines the callbacks to be implemented by any messaging provider.
  """

  alias MessagingService.Schemas.Message

  @doc """
  Sends a message to the provider.
  """
  @callback send_message(message :: Message.t()) :: {:ok, Message.t()} | {:error, map()}

  @doc """
  Receives a message from the provider.
  """
  @callback receive_message(message :: Message.t()) :: {:ok, Message.t()} | {:error, map()}
end
