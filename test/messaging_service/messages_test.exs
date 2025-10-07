defmodule MessagingService.MessagesTest do
  @moduledoc """
  Tests for the MessagingService.Messages module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Messages
  alias MessagingService.Schemas.Contact
  import MessagingService.Fixtures

  describe "get_new_message_assocs/1" do
    test "returns associations for SMS message with phone numbers" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id != nil
      assert result.to_number_id != nil
      assert result.from_email_id == nil
      assert result.to_email_id == nil
    end

    test "returns associations for email message with email addresses" do
      params = %{
        "type" => "email",
        "from" => "sender@example.com",
        "to" => "recipient@example.com",
        "body" => "Test message"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id == nil
      assert result.to_number_id == nil
      assert result.from_email_id != nil
      assert result.to_email_id != nil
    end

    test "creates new contacts when they don't exist" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id != nil
      assert result.to_number_id != nil
    end

    test "uses existing contacts when they exist" do
      phone1 = contact_phone_number_fixture(%{number: "+1234567890"})
      phone2 = contact_phone_number_fixture(%{number: "+0987654321"})
      contact1 = Repo.get!(Contact, phone1.contact_id)
      contact2 = Repo.get!(Contact, phone2.contact_id)
      conversation = conversation_fixture()
      insert_conversation_contact(conversation, contact1)
      insert_conversation_contact(conversation, contact2)

      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id == conversation.id
      assert result.from_number_id == phone1.id
      assert result.to_number_id == phone2.id
    end

    test "creates new conversation when it doesn't exist" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
    end

    test "handles MMS message type" do
      params = %{
        "type" => "mms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message",
        "attachments" => ["image1.jpg"]
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id != nil
      assert result.to_number_id != nil
      assert result.from_email_id == nil
      assert result.to_email_id == nil
    end

    test "handles email message type" do
      params = %{
        "type" => "email",
        "from" => "sender@example.com",
        "to" => "recipient@example.com",
        "body" => "Test message",
        "subject" => "Test Subject"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id == nil
      assert result.to_number_id == nil
      assert result.from_email_id != nil
      assert result.to_email_id != nil
    end

    test "returns consistent IDs for same contacts" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321",
        "body" => "Test message"
      }

      result1 = Messages.get_new_message_assocs(params)
      result2 = Messages.get_new_message_assocs(params)

      assert result1.conversation_id == result2.conversation_id
      assert result1.from_number_id == result2.from_number_id
      assert result1.to_number_id == result2.to_number_id
    end

    test "handles missing optional fields" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      result = Messages.get_new_message_assocs(params)

      assert result.conversation_id != nil
      assert result.from_number_id != nil
      assert result.to_number_id != nil
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
end
