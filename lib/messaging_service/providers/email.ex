defmodule MessagingService.Providers.Email do
  @moduledoc """
  Email provider.
  """
  @behaviour MessagingService.Providers.Behaviour

  alias MessagingService.Schemas.Message
  alias MessagingService.Messages
  alias MessagingService.Repo

  @impl MessagingService.Providers.Behaviour
  def send_message(message) do
    http_client = Application.get_env(:messaging_service, :http_client, MessagingService.HTTPClientMock)

    {:ok, response} =
      http_client.post("http://localhost:4000/api/webhooks/mock_send_response",
        json: JSON.encode!(message)
      )

    new_message_assocs = Messages.get_new_message_assocs(message)

    case response.status do
      n when n in 200..299 ->
        Repo.insert(
          Message.changeset(
            %Message{},
            Map.merge(new_message_assocs, ExUtils.Map.atomize_keys(message))
          )
        )

        {:ok, response.body}

      _ ->
        {:error, response}
    end
  end

  @impl MessagingService.Providers.Behaviour
  def receive_message(message) do
    new_message_assocs = Messages.get_new_message_assocs(message)

    Repo.insert(
      Message.changeset(
        %Message{},
        Map.merge(new_message_assocs, ExUtils.Map.atomize_keys(message))
      )
    )
  end
end
