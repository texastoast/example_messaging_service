defmodule MessagingService.Providers.Email do
  @moduledoc """
  Email provider.
  """
  @behaviour MessagingService.Providers.Behaviour

  alias MessagingService.Schemas.Message

  @spec send_message(Message.t()) :: {:ok, Message.t()} | {:error, map()}
  def send_message(message) do
    # TODO: Implement Email send
    {:ok, message}
  end

  @spec receive_message(Message.t()) :: {:ok, Message.t()} | {:error, map()}
  def receive_message(message) do
    # TODO: Implement Email receive
    {:ok, message}
  end
end
