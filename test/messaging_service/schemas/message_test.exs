defmodule MessagingService.Schemas.MessageTest do
  @moduledoc """
  Tests for the MessagingService.Schemas.Message module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Schemas.Message
  import MessagingService.Fixtures

  describe "changeset/2" do
    test "valid changeset with SMS message and phone numbers" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_number = contact_phone_number_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_number_id: to_number.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.type == :sms
      assert changeset.changes.body == "Hello, world!"
      assert changeset.changes.conversation_id == conversation.id
      assert changeset.changes.from_number_id == from_number.id
      assert changeset.changes.to_number_id == to_number.id
    end

    test "valid changeset with email message and email addresses" do
      conversation = conversation_fixture()
      from_email = contact_email_fixture()
      to_email = contact_email_fixture()

      attrs = %{
        type: :email,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_email_id: from_email.id,
        to_email_id: to_email.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.type == :email
      assert changeset.changes.body == "Hello, world!"
      assert changeset.changes.conversation_id == conversation.id
      assert changeset.changes.from_email_id == from_email.id
      assert changeset.changes.to_email_id == to_email.id
    end

    test "valid changeset with MMS message and attachments" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_number = contact_phone_number_fixture()

      attrs = %{
        type: :mms,
        body: "Check out these images!",
        attachments: ["image1.jpg", "image2.png"],
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_number_id: to_number.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.type == :mms
      assert changeset.changes.body == "Check out these images!"
      assert changeset.changes.attachments == ["image1.jpg", "image2.png"]
      assert changeset.changes.conversation_id == conversation.id
    end

    test "invalid changeset without required type" do
      conversation = conversation_fixture()

      attrs = %{
        body: "Hello, world!",
        conversation_id: conversation.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).type
    end

    test "invalid changeset without required body" do
      conversation = conversation_fixture()

      attrs = %{
        type: :sms,
        conversation_id: conversation.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).body
    end

    test "invalid changeset without required conversation_id" do
      attrs = %{
        type: :sms,
        body: "Hello, world!"
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).conversation_id
    end

    test "invalid changeset with invalid type" do
      conversation = conversation_fixture()

      attrs = %{
        type: :invalid_type,
        body: "Hello, world!",
        conversation_id: conversation.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).type
    end

    test "invalid changeset without contact methods" do
      conversation = conversation_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        conversation_id: conversation.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?

      assert "must provide either from/to phone numbers or from/to email addresses" in errors_on(
               changeset
             ).contact_methods
    end

    test "invalid changeset with only from_number (missing to_number)" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_number_id: from_number.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?

      assert "must provide either from/to phone numbers or from/to email addresses" in errors_on(
               changeset
             ).contact_methods
    end

    test "invalid changeset with only from_email (missing to_email)" do
      conversation = conversation_fixture()
      from_email = contact_email_fixture()

      attrs = %{
        type: :email,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_email_id: from_email.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?

      assert "must provide either from/to phone numbers or from/to email addresses" in errors_on(
               changeset
             ).contact_methods
    end

    test "invalid changeset with mixed contact methods" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_email = contact_email_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_email_id: to_email.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?

      assert "must provide either from/to phone numbers or from/to email addresses" in errors_on(
               changeset
             ).contact_methods
    end

    test "valid changeset with empty attachments" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_number = contact_phone_number_fixture()

      attrs = %{
        type: :mms,
        body: "No attachments",
        attachments: [],
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_number_id: to_number.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.attachments == []
    end

    test "valid changeset with messaging_provider_id" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_number = contact_phone_number_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        messaging_provider_id: "provider_123",
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_number_id: to_number.id
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.messaging_provider_id == "provider_123"
    end

    test "ignores unknown attributes" do
      conversation = conversation_fixture()
      from_number = contact_phone_number_fixture()
      to_number = contact_phone_number_fixture()

      attrs = %{
        type: :sms,
        body: "Hello, world!",
        conversation_id: conversation.id,
        from_number_id: from_number.id,
        to_number_id: to_number.id,
        unknown_field: "should be ignored"
      }

      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :unknown_field)
    end
  end

  describe "schema fields" do
    test "has required fields" do
      message = %Message{}

      assert Map.has_key?(message, :id)
      assert Map.has_key?(message, :type)
      assert Map.has_key?(message, :body)
      assert Map.has_key?(message, :attachments)
      assert Map.has_key?(message, :messaging_provider_id)
      assert Map.has_key?(message, :conversation_id)
      assert Map.has_key?(message, :from_number_id)
      assert Map.has_key?(message, :to_number_id)
      assert Map.has_key?(message, :from_email_id)
      assert Map.has_key?(message, :to_email_id)
      assert Map.has_key?(message, :inserted_at)
      assert Map.has_key?(message, :updated_at)
    end

    test "has associations" do
      message = %Message{}

      assert Map.has_key?(message, :conversation)
      assert Map.has_key?(message, :from_number)
      assert Map.has_key?(message, :to_number)
      assert Map.has_key?(message, :from_email)
      assert Map.has_key?(message, :to_email)
    end
  end
end
