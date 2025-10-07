defmodule MessagingServiceWeb.WebhooksController do
  use MessagingServiceWeb, :controller

  alias MessagingService.Providers.Provider
  alias MessagingService.Conversations
  alias MessagingService.ApiHelpers

  @spec mock_send_response(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def mock_send_response(conn, params) do
    message =
      Map.put(
        JSON.decode!(Map.get(params, "_json")),
        :messaging_provider_id,
        Ecto.UUID.generate()
      )

    conn |> json(message)

    # Uncomment to simulate a rate limit error
    # conn
    # |> put_status(:too_many_requests)
    # |> json(%{
    #   error: "Rate limit exceeded",
    #   message: "Too many requests. Please try again later.",
    #   retry_after: 60
    # })
  end

  @spec send_message(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def send_message(conn, params) do
    params =
      if Map.get(params, "type") == "sms" and Map.get(params, "attachments", nil) != nil do
        Map.put(params, "type", "mms")
      else
        params
      end

    case Provider.send_message(params) do
      {:ok, message} ->
        conn |> json(message)

      {:error, response} ->
        conn |> put_status(response.status) |> json(Map.from_struct(response))
    end
  end

  @spec receive_message(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def receive_message(conn, params) do
    case Provider.receive_message(params) do
      {:ok, message} ->
        conn |> json(message)

      {:error, response} ->
        conn |> put_status(response.status) |> json(Map.from_struct(response))
    end
  end

  @spec get_conversations(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_conversations(conn, _params) do
    conversations = ApiHelpers.convert_to_map(Conversations.list_conversations())
    conn |> json(conversations)
  end

  @spec get_messages_for_conversation(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_messages_for_conversation(conn, params) do
    messages =
      ApiHelpers.convert_to_map(
        Conversations.list_messages_for_conversation(Map.get(params, "id"))
      )

    conn |> json(messages)
  end
end
