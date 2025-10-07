defmodule MessagingService.Providers.Provider do
  @moduledoc """
  The outward interface for interacting with a provider integration.
  """

  @type provider :: :sms | :mms | :email

  @spec send_message(map()) :: {:ok, map()} | {:error, map()}
  def send_message(message) do
    case get_provider(Map.get(message, "type")).send_message(message) do
      {:ok, response} ->
        {:ok, response}

      {:error, response} ->
        {:error, response}
    end
  end

  @spec receive_message(map()) :: {:ok, map()} | {:error, map()}
  def receive_message(message) do
    case get_provider(Map.get(message, "type")).receive_message(message) do
      {:ok, message} ->
        {:ok, message}

      {:error, response} ->
        {:error, response}
    end
  end

  defp get_provider("sms"), do: MessagingService.Providers.Sms
  defp get_provider("mms"), do: MessagingService.Providers.Mms
  defp get_provider("email"), do: MessagingService.Providers.Email
end
