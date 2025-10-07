defmodule MessagingServiceWeb.WebhooksControllerTest do
  @moduledoc """
  Tests for the MessagingServiceWeb.WebhooksController module.
  """

  use MessagingServiceWeb.ConnCase, async: true

  alias MessagingServiceWeb.WebhooksController
  import MessagingService.Fixtures
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "mock_send_response/2" do
    test "returns JSON response with messaging_provider_id", %{conn: conn} do
      message_data = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      params = %{"_json" => Jason.encode!(message_data)}

      conn = WebhooksController.mock_send_response(conn, params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "sms"
      assert response_data["body"] == "Test message"
      assert response_data["from"] == "+1234567890"
      assert response_data["to"] == "+0987654321"
      assert response_data["messaging_provider_id"] != nil
      assert is_binary(response_data["messaging_provider_id"])
    end

    test "handles invalid JSON gracefully", %{conn: conn} do
      params = %{"_json" => "invalid json"}

      assert_raise JSON.DecodeError, fn ->
        WebhooksController.mock_send_response(conn, params)
      end
    end
  end

  describe "send_message/2" do
    test "sends SMS message successfully", %{conn: conn} do
      params = sms_message_fixture()

      # Mock the HTTP request
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        assert opts[:json] == Jason.encode!(params)

        {:ok, %Req.Response{
          status: 200,
          body: %{
            "type" => "sms",
            "body" => params["body"],
            "from" => params["from"],
            "to" => params["to"],
            "messaging_provider_id" => Ecto.UUID.generate()
          }
        }}
      end)

      conn = post(conn, ~p"/api/messages/sms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "sms"
      assert response_data["body"] == params["body"]
    end

    test "sends MMS message successfully", %{conn: conn} do
      params = mms_message_fixture()

      # Mock the HTTP request
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        assert opts[:json] == Jason.encode!(params)

        {:ok, %Req.Response{
          status: 200,
          body: %{
            "type" => "mms",
            "body" => params["body"],
            "from" => params["from"],
            "to" => params["to"],
            "attachments" => params["attachments"],
            "messaging_provider_id" => Ecto.UUID.generate()
          }
        }}
      end)

      conn = post(conn, ~p"/api/messages/mms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "mms"
      assert response_data["body"] == params["body"]
    end

    test "sends email message successfully", %{conn: conn} do
      params = email_message_fixture()

      # Mock the HTTP request
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        assert opts[:json] == Jason.encode!(params)

        {:ok, %Req.Response{
          status: 200,
          body: %{
            "type" => "email",
            "body" => params["body"],
            "from" => params["from"],
            "to" => params["to"],
            "subject" => params["subject"],
            "messaging_provider_id" => Ecto.UUID.generate()
          }
        }}
      end)

      conn = post(conn, ~p"/api/messages/email", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "email"
      assert response_data["body"] == params["body"]
    end

    test "converts SMS to MMS when attachments are present", %{conn: conn} do
      params = %{
        "type" => "sms",
        "body" => "Test message with attachment",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "attachments" => ["image.jpg"]
      }

      # Mock the HTTP request
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        # The controller should convert SMS to MMS when attachments are present
        expected_params = Map.put(params, "type", "mms")
        assert opts[:json] == Jason.encode!(expected_params)

        {:ok, %Req.Response{
          status: 200,
          body: %{
            "type" => "mms",
            "body" => params["body"],
            "from" => params["from"],
            "to" => params["to"],
            "attachments" => params["attachments"],
            "messaging_provider_id" => Ecto.UUID.generate()
          }
        }}
      end)

      conn = post(conn, ~p"/api/messages/sms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "mms"
      assert response_data["body"] == params["body"]
    end

    test "handles provider errors", %{conn: conn} do
      params = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      # Mock the HTTP request to return an error
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        assert opts[:json] == Jason.encode!(params)

        error_response = %Req.Response{
          status: 400,
          body: %{
            "error" => "Bad request",
            "message" => "Invalid parameters"
          }
        }

        {:ok, error_response}
      end)

      conn = post(conn, ~p"/api/messages/sms", params)

      assert json_response(conn, 400)
      response_data = json_response(conn, 400)
      assert response_data["status"] == 400
      assert response_data["body"]["error"] == "Bad request"
    end

    test "handles missing required fields", %{conn: conn} do
      params = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      # Mock the HTTP request
      expect(MessagingService.HTTPClientMock, :post, fn url, opts ->
        assert url == "http://localhost:4000/api/webhooks/mock_send_response"
        assert opts[:json] == Jason.encode!(params)

        {:ok, %Req.Response{
          status: 200,
          body: %{
            "type" => "sms",
            "body" => params["body"],
            "from" => params["from"],
            "to" => params["to"],
            "messaging_provider_id" => Ecto.UUID.generate()
          }
        }}
      end)

      conn = post(conn, ~p"/api/messages/sms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "sms"
    end
  end

  describe "receive_message/2" do
    test "receives SMS message successfully", %{conn: conn} do
      params = sms_message_fixture()

      conn = post(conn, ~p"/api/webhooks/sms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "sms"
      assert response_data["body"] == params["body"]
    end

    test "receives MMS message successfully", %{conn: conn} do
      params = mms_message_fixture()

      conn = post(conn, ~p"/api/webhooks/mms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "mms"
      assert response_data["body"] == params["body"]
    end

    test "receives email message successfully", %{conn: conn} do
      params = email_message_fixture()

      conn = post(conn, ~p"/api/webhooks/email", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "email"
      assert response_data["body"] == params["body"]
    end

    test "handles missing required fields", %{conn: conn} do
      params = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      conn = post(conn, ~p"/api/webhooks/sms", params)

      assert json_response(conn, 200)
      response_data = json_response(conn, 200)
      assert response_data["type"] == "sms"
    end
  end

  describe "get_conversations/2" do
    test "returns empty list when no conversations exist", %{conn: conn} do
      conn = get(conn, ~p"/api/conversations")

      assert json_response(conn, 200) == []
    end

    test "returns conversations when they exist", %{conn: conn} do
      _conversation1 = conversation_fixture()
      _conversation2 = conversation_fixture()

      conn = get(conn, ~p"/api/conversations")

      assert json_response(conn, 200)
      conversations = json_response(conn, 200)
      assert length(conversations) == 2
      assert Enum.all?(conversations, &Map.has_key?(&1, "id"))
      assert Enum.all?(conversations, &Map.has_key?(&1, "inserted_at"))
    end

    test "returns conversations with proper structure", %{conn: conn} do
      _conversation = conversation_fixture()

      conn = get(conn, ~p"/api/conversations")

      assert json_response(conn, 200)
      conversations = json_response(conn, 200)
      conversation = List.first(conversations)

      assert Map.has_key?(conversation, "id")
      assert Map.has_key?(conversation, "inserted_at")
      assert Map.has_key?(conversation, "updated_at")
      assert is_binary(conversation["id"])
      assert is_binary(conversation["inserted_at"])
      assert is_binary(conversation["updated_at"])
    end
  end

  describe "get_messages_for_conversation/2" do
    test "returns empty list when no messages exist for conversation", %{conn: conn} do
      conversation = conversation_fixture()

      conn = get(conn, ~p"/api/conversations/#{conversation.id}/messages")

      assert json_response(conn, 200) == []
    end

    test "returns messages when they exist for conversation", %{conn: conn} do
      conversation = conversation_fixture()
      _message1 = insert_message(conversation, "First message")
      _message2 = insert_message(conversation, "Second message")

      conn = get(conn, ~p"/api/conversations/#{conversation.id}/messages")

      assert json_response(conn, 200)
      messages = json_response(conn, 200)
      assert length(messages) == 2
      assert Enum.all?(messages, &Map.has_key?(&1, "id"))
      assert Enum.all?(messages, &Map.has_key?(&1, "body"))
    end

    test "returns messages with proper structure", %{conn: conn} do
      conversation = conversation_fixture()
      _message = insert_message(conversation, "Test message")

      conn = get(conn, ~p"/api/conversations/#{conversation.id}/messages")

      assert json_response(conn, 200)
      messages = json_response(conn, 200)
      message = List.first(messages)

      assert Map.has_key?(message, "id")
      assert Map.has_key?(message, "type")
      assert Map.has_key?(message, "body")
      assert Map.has_key?(message, "conversation_id")
      assert Map.has_key?(message, "inserted_at")
      assert Map.has_key?(message, "updated_at")
      assert is_binary(message["id"])
      assert is_binary(message["type"])
      assert is_binary(message["body"])
      assert is_binary(message["conversation_id"])
      assert is_binary(message["inserted_at"])
      assert is_binary(message["updated_at"])
    end

    test "returns only messages for specified conversation", %{conn: conn} do
      conversation1 = conversation_fixture()
      conversation2 = conversation_fixture()
      _message1 = insert_message(conversation1, "Message 1")
      _message2 = insert_message(conversation2, "Message 2")

      conn = get(conn, ~p"/api/conversations/#{conversation1.id}/messages")

      assert json_response(conn, 200)
      messages = json_response(conn, 200)
      assert length(messages) == 1
      message = List.first(messages)
      assert message["body"] == "Message 1"
    end

    test "handles non-existent conversation ID", %{conn: conn} do
      fake_id = Ecto.UUID.generate()

      conn = get(conn, ~p"/api/conversations/#{fake_id}/messages")

      assert json_response(conn, 200) == []
    end
  end

  defp insert_message(conversation, body) do
    phone1 = contact_phone_number_fixture(%{number: "+1234567890"})
    phone2 = contact_phone_number_fixture(%{number: "+0987654321"})

    %MessagingService.Schemas.Message{}
    |> MessagingService.Schemas.Message.changeset(%{
      type: :sms,
      body: body,
      conversation_id: conversation.id,
      from_number_id: phone1.id,
      to_number_id: phone2.id,
      from_email_id: nil,
      to_email_id: nil
    })
    |> MessagingService.Repo.insert!()
  end
end
