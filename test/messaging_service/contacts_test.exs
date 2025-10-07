defmodule MessagingService.ContactsTest do
  @moduledoc """
  Tests for the MessagingService.Contacts module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Contacts
  alias MessagingService.Schemas.Contact
  import MessagingService.Fixtures

  describe "find_or_create_contact_by_phone_number/1" do
    test "finds existing contact by phone number" do
      phone_number = contact_phone_number_fixture(%{number: "+1234567890"})
      contact = Repo.get!(Contact, phone_number.contact_id)

      result = Contacts.find_or_create_contact_by_phone_number("+1234567890")

      assert result.id == contact.id
      assert length(result.contact_phone_numbers) == 1
      assert Enum.at(result.contact_phone_numbers, 0).number == "+1234567890"
    end

    test "creates new contact and phone number when not found" do
      result = Contacts.find_or_create_contact_by_phone_number("+1234567890")

      assert result.id != nil
      assert length(result.contact_phone_numbers) == 1
      assert Enum.at(result.contact_phone_numbers, 0).number == "+1234567890"
    end

    test "returns contact with preloaded associations" do
      result = Contacts.find_or_create_contact_by_phone_number("+1234567890")

      assert %Ecto.Association.NotLoaded{} != result.contact_phone_numbers
      assert %Ecto.Association.NotLoaded{} != result.contact_emails
    end
  end

  describe "find_or_create_contact_by_email/1" do
    test "finds existing contact by email" do
      email = contact_email_fixture(%{email: "test@example.com"})
      contact = Repo.get!(Contact, email.contact_id)

      result = Contacts.find_or_create_contact_by_email("test@example.com")

      assert result.id == contact.id
      assert length(result.contact_emails) == 1
      assert Enum.at(result.contact_emails, 0).email == "test@example.com"
    end

    test "creates new contact and email when not found" do
      result = Contacts.find_or_create_contact_by_email("test@example.com")

      assert result.id != nil
      assert length(result.contact_emails) == 1
      assert Enum.at(result.contact_emails, 0).email == "test@example.com"
    end

    test "creates contact with empty name" do
      result = Contacts.find_or_create_contact_by_email("test@example.com")

      assert result.name == ""
    end

    test "returns contact with preloaded associations" do
      result = Contacts.find_or_create_contact_by_email("test@example.com")

      assert %Ecto.Association.NotLoaded{} != result.contact_phone_numbers
      assert %Ecto.Association.NotLoaded{} != result.contact_emails
    end
  end

  describe "find_phone_number_id_by_number/2" do
    test "finds phone number ID by number" do
      phone_number = contact_phone_number_fixture(%{number: "+1234567890"})
      contact = Repo.get!(Contact, phone_number.contact_id)
      contact = Repo.preload(contact, :contact_phone_numbers)

      result = Contacts.find_phone_number_id_by_number(contact, "+1234567890")

      assert result == phone_number.id
    end

    test "returns nil when phone number not found" do
      contact = contact_fixture()
      contact = Repo.preload(contact, :contact_phone_numbers)

      result = Contacts.find_phone_number_id_by_number(contact, "+1234567890")

      assert result == nil
    end

    test "returns nil when contact has no phone numbers" do
      contact = contact_fixture()
      contact = Repo.preload(contact, :contact_phone_numbers)

      result = Contacts.find_phone_number_id_by_number(contact, "+1234567890")

      assert result == nil
    end
  end

  describe "find_email_id_by_address/2" do
    test "finds email ID by address" do
      email = contact_email_fixture(%{email: "test@example.com"})
      contact = Repo.get!(Contact, email.contact_id)
      contact = Repo.preload(contact, :contact_emails)

      result = Contacts.find_email_id_by_address(contact, "test@example.com")

      assert result == email.id
    end

    test "returns nil when email not found" do
      contact = contact_fixture()
      contact = Repo.preload(contact, :contact_emails)

      result = Contacts.find_email_id_by_address(contact, "test@example.com")

      assert result == nil
    end

    test "returns nil when contact has no emails" do
      contact = contact_fixture()
      contact = Repo.preload(contact, :contact_emails)

      result = Contacts.find_email_id_by_address(contact, "test@example.com")

      assert result == nil
    end
  end

  describe "get_contact_info_by_type/1" do
    test "returns phone number contacts for SMS type" do
      params = %{
        "type" => "sms",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      result = Contacts.get_contact_info_by_type(params)

      assert result.from.id != nil
      assert result.to.id != nil
      assert length(result.from.contact_phone_numbers) == 1
      assert length(result.to.contact_phone_numbers) == 1
      assert Enum.at(result.from.contact_phone_numbers, 0).number == "+1234567890"
      assert Enum.at(result.to.contact_phone_numbers, 0).number == "+0987654321"
    end

    test "returns email contacts for email type" do
      params = %{
        "type" => "email",
        "from" => "sender@example.com",
        "to" => "recipient@example.com"
      }

      result = Contacts.get_contact_info_by_type(params)

      assert result.from.id != nil
      assert result.to.id != nil
      assert length(result.from.contact_emails) == 1
      assert length(result.to.contact_emails) == 1
      assert Enum.at(result.from.contact_emails, 0).email == "sender@example.com"
      assert Enum.at(result.to.contact_emails, 0).email == "recipient@example.com"
    end

    test "defaults to phone number contacts for unknown type" do
      params = %{
        "type" => "unknown",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      result = Contacts.get_contact_info_by_type(params)

      assert result.from.id != nil
      assert result.to.id != nil
      assert length(result.from.contact_phone_numbers) == 1
      assert length(result.to.contact_phone_numbers) == 1
    end
  end

  describe "get_contact_method_ids/3" do
    test "returns email ID for email type" do
      email = contact_email_fixture(%{email: "test@example.com"})
      contact = Repo.get!(Contact, email.contact_id)

      {phone_id, email_id} = Contacts.get_contact_method_ids(contact, "test@example.com", "email")

      assert phone_id == nil
      assert email_id == email.id
    end

    test "returns phone ID for non-email type" do
      phone_number = contact_phone_number_fixture(%{number: "+1234567890"})
      contact = Repo.get!(Contact, phone_number.contact_id)

      {phone_id, email_id} = Contacts.get_contact_method_ids(contact, "+1234567890", "sms")

      assert phone_id == phone_number.id
      assert email_id == nil
    end

    test "returns nil when email not found" do
      contact = contact_fixture()

      {phone_id, email_id} = Contacts.get_contact_method_ids(contact, "nonexistent@example.com", "email")

      assert phone_id == nil
      assert email_id == nil
    end

    test "returns nil when phone number not found" do
      contact = contact_fixture()

      {phone_id, email_id} = Contacts.get_contact_method_ids(contact, "+9999999999", "sms")

      assert phone_id == nil
      assert email_id == nil
    end
  end

end
