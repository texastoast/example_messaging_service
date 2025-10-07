defmodule MessagingService.Fixtures do
  @moduledoc """
  Test fixtures for the messaging service.
  """

  alias MessagingService.Repo
  alias MessagingService.Schemas.{Contact, ContactPhoneNumber, ContactEmail, Conversation}

  @doc """
  Creates a contact fixture.
  """
  def contact_fixture(attrs \\ %{}) do
    default_attrs = %{
      name: "Test Contact",
      email: "test@example.com"
    }

    attrs = Enum.into(attrs, default_attrs)

    {:ok, contact} =
      %Contact{}
      |> Contact.changeset(attrs)
      |> Repo.insert()

    contact
  end

  @doc """
  Creates a contact phone number fixture.
  """
  def contact_phone_number_fixture(attrs \\ %{}) do
    contact = contact_fixture()

    default_attrs = %{
      contact_id: contact.id,
      number: "+1234567890"
    }

    attrs = Enum.into(attrs, default_attrs)

    {:ok, phone_number} =
      %ContactPhoneNumber{}
      |> ContactPhoneNumber.changeset(attrs)
      |> Repo.insert()

    phone_number
  end

  @doc """
  Creates a contact email fixture.
  """
  def contact_email_fixture(attrs \\ %{}) do
    contact = contact_fixture()

    default_attrs = %{
      contact_id: contact.id,
      email: "test@example.com"
    }

    attrs = Enum.into(attrs, default_attrs)

    {:ok, email} =
      %ContactEmail{}
      |> ContactEmail.changeset(attrs)
      |> Repo.insert()

    email
  end

  @doc """
  Creates a conversation fixture.
  """
  def conversation_fixture(attrs \\ %{}) do
    contact1 = contact_fixture()
    contact2 = contact_fixture(%{name: "Test Contact 2", email: "test2@example.com"})

    default_attrs = %{
      contact1_id: contact1.id,
      contact2_id: contact2.id
    }

    attrs = Enum.into(attrs, default_attrs)

    {:ok, conversation} =
      %Conversation{}
      |> Conversation.changeset(attrs)
      |> Repo.insert()

    conversation
  end

  @doc """
  Creates a valid SMS message map for testing.
  """
  def sms_message_fixture(attrs \\ %{}) do
    default_attrs = %{
      "type" => "sms",
      "body" => "Test SMS message",
      "from" => "+1234567890",
      "to" => "+0987654321",
      "messaging_provider_id" => "test_provider"
    }

    Enum.into(attrs, default_attrs)
  end

  @doc """
  Creates a valid MMS message map for testing.
  """
  def mms_message_fixture(attrs \\ %{}) do
    default_attrs = %{
      "type" => "mms",
      "body" => "Test MMS message",
      "from" => "+1234567890",
      "to" => "+0987654321",
      "attachments" => ["image1.jpg", "image2.png"],
      "messaging_provider_id" => "test_provider"
    }

    Enum.into(attrs, default_attrs)
  end

  @doc """
  Creates a valid email message map for testing.
  """
  def email_message_fixture(attrs \\ %{}) do
    default_attrs = %{
      "type" => "email",
      "body" => "Test email message",
      "from" => "sender@example.com",
      "to" => "recipient@example.com",
      "subject" => "Test Subject",
      "messaging_provider_id" => "test_provider"
    }

    Enum.into(attrs, default_attrs)
  end

  @doc """
  Creates a mock HTTP response for successful requests.
  """
  def mock_success_response(attrs \\ %{}) do
    default_attrs = %{
      status: 200,
      body: %{"status" => "success", "message_id" => "test_message_id"}
    }

    Enum.into(attrs, default_attrs)
  end

  @doc """
  Creates a mock HTTP response for failed requests.
  """
  def mock_error_response(attrs \\ %{}) do
    default_attrs = %{
      status: 400,
      body: %{"status" => "error", "message" => "Bad request"}
    }

    Enum.into(attrs, default_attrs)
  end
end
