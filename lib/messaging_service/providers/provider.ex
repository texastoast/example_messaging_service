defmodule MessagingService.Providers.Provider do
  @moduledoc """
  The outward interface for interacting with a provider integration.
  """

  alias MessagingService.Schemas.Message
  alias MessagingService.Structs.NewMessage

  @type provider :: :sms | :mms | :email


  @spec send_message(NewMessage.t()) :: {:ok, Message.t()} | {:error, map()}
  def send_message(message) do
    get_provider(message.type).send_message(message)
  end

  @spec receive_message(NewMessage.t()) :: {:ok, Message.t()} | {:error, map()}
  def receive_message(message) do
    get_provider(message.type).receive_message(message)
  end

  defp get_provider(:sms), do: MessagingService.Providers.Sms
  defp get_provider(:mms), do: MessagingService.Providers.Mms
  defp get_provider(:email), do: MessagingService.Providers.Email
end
