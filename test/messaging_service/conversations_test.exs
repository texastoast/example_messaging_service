defmodule MessagingService.ConversationsTest do
  @moduledoc """
  Tests for the MessagingService.Conversations module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Conversations
  alias MessagingService.Schemas.Message
  import MessagingService.Fixtures

  describe "list_conversations/0" do
    test "returns conversations ordered by most recent first" do
      _conversation1 = conversation_fixture()
      _conversation2 = conversation_fixture()

      result = Conversations.list_conversations()

      assert length(result) == 2
      assert Enum.at(result, 0).inserted_at >= Enum.at(result, 1).inserted_at
    end

    test "returns conversations with preloaded contacts" do
      _conversation = conversation_fixture()

      result = Conversations.list_conversations()

      assert length(result) == 1
      conversation_result = Enum.at(result, 0)
      assert %Ecto.Association.NotLoaded{} != conversation_result.contacts
    end

    test "returns empty list when no conversations exist" do
      result = Conversations.list_conversations()

      assert result == []
    end
  end

  describe "list_messages_for_conversation/1" do
    test "returns messages for conversation ordered by most recent first" do
      conversation = conversation_fixture()
      _message1 = insert_message(conversation, "First message")
      _message2 = insert_message(conversation, "Second message")

      result = Conversations.list_messages_for_conversation(conversation.id)

      assert length(result) == 2
      assert Enum.at(result, 0).inserted_at >= Enum.at(result, 1).inserted_at
    end

    test "returns only messages for specified conversation" do
      conversation1 = conversation_fixture()
      conversation2 = conversation_fixture()
      message1 = insert_message(conversation1, "Message 1")
      _message2 = insert_message(conversation2, "Message 2")

      result = Conversations.list_messages_for_conversation(conversation1.id)

      assert length(result) == 1
      assert Enum.at(result, 0).id == message1.id
    end

    test "returns empty list when no messages exist for conversation" do
      conversation = conversation_fixture()

      result = Conversations.list_messages_for_conversation(conversation.id)

      assert result == []
    end
  end

  describe "find_or_create_conversation_by_contacts/1" do
    test "finds existing conversation with exact same contacts" do
      contact1 = contact_fixture()
      contact2 = contact_fixture()
      conversation = conversation_fixture()
      insert_conversation_contact(conversation, contact1)
      insert_conversation_contact(conversation, contact2)

      result = Conversations.find_or_create_conversation_by_contacts([contact1, contact2])

      assert result.id == conversation.id
    end

    test "creates new conversation when none exists with exact contacts" do
      contact1 = contact_fixture()
      contact2 = contact_fixture()

      result = Conversations.find_or_create_conversation_by_contacts([contact1, contact2])

      assert result.id != nil
      assert result.id != contact1.id
      assert result.id != contact2.id
    end

    test "creates new conversation when existing conversation has different contacts" do
      contact1 = contact_fixture()
      contact2 = contact_fixture()
      contact3 = contact_fixture()
      existing_conversation = conversation_fixture()
      insert_conversation_contact(existing_conversation, contact1)
      insert_conversation_contact(existing_conversation, contact3)

      result = Conversations.find_or_create_conversation_by_contacts([contact1, contact2])

      assert result.id != existing_conversation.id
      assert result.id != nil
    end

    test "creates new conversation when existing conversation has subset of contacts" do
      contact1 = contact_fixture()
      contact2 = contact_fixture()
      contact3 = contact_fixture()
      existing_conversation = conversation_fixture()
      insert_conversation_contact(existing_conversation, contact1)

      result = Conversations.find_or_create_conversation_by_contacts([contact1, contact2, contact3])

      assert result.id != existing_conversation.id
      assert result.id != nil
    end

    test "handles single contact" do
      contact = contact_fixture()

      result = Conversations.find_or_create_conversation_by_contacts([contact])

      assert result.id != nil
    end

    test "handles empty contact list" do
      result = Conversations.find_or_create_conversation_by_contacts([])

      assert result.id != nil
    end
  end


  defp insert_conversation_contact(conversation, contact) do
    conversation = Repo.preload(conversation, :contacts)
    existing_contacts = conversation.contacts
    conversation
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:contacts, existing_contacts ++ [contact])
    |> Repo.update!()
  end

  defp insert_message(conversation, body) do
    phone1 = contact_phone_number_fixture(%{number: "+1234567890"})
    phone2 = contact_phone_number_fixture(%{number: "+0987654321"})

    %Message{}
    |> Message.changeset(%{
      type: :sms,
      body: body,
      conversation_id: conversation.id,
      from_number_id: phone1.id,
      to_number_id: phone2.id,
      from_email_id: nil,
      to_email_id: nil
    })
    |> Repo.insert!()
  end
end
