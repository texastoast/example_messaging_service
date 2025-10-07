defmodule MessagingService.Schemas.ContactEmailTest do
  @moduledoc """
  Tests for the MessagingService.Schemas.ContactEmail module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Schemas.ContactEmail
  import MessagingService.Fixtures

  describe "changeset/2" do
    test "valid changeset with valid attributes" do
      contact = contact_fixture()
      attrs = %{email: "john@example.com", contact_id: contact.id}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      assert changeset.valid?
      assert changeset.changes.email == "john@example.com"
      assert changeset.changes.contact_id == contact.id
    end

    test "invalid changeset without required email" do
      contact = contact_fixture()
      attrs = %{contact_id: contact.id}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid changeset without required contact_id" do
      attrs = %{email: "john@example.com"}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).contact_id
    end

    test "invalid changeset with empty email" do
      contact = contact_fixture()
      attrs = %{email: "", contact_id: contact.id}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid changeset with nil email" do
      contact = contact_fixture()
      attrs = %{email: nil, contact_id: contact.id}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid changeset with nil contact_id" do
      attrs = %{email: "john@example.com", contact_id: nil}

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).contact_id
    end

    test "valid changeset with various email formats" do
      contact = contact_fixture()

      valid_emails = [
        "user@example.com",
        "user.name@example.com",
        "user+tag@example.com",
        "user123@example-domain.com"
      ]

      for email <- valid_emails do
        attrs = %{email: email, contact_id: contact.id}
        changeset = ContactEmail.changeset(%ContactEmail{}, attrs)
        assert changeset.valid?, "Email #{email} should be valid"
      end
    end

    test "ignores unknown attributes" do
      contact = contact_fixture()

      attrs = %{
        email: "john@example.com",
        contact_id: contact.id,
        unknown_field: "should be ignored"
      }

      changeset = ContactEmail.changeset(%ContactEmail{}, attrs)

      assert changeset.valid?
      assert changeset.changes.email == "john@example.com"
      assert changeset.changes.contact_id == contact.id
      refute Map.has_key?(changeset.changes, :unknown_field)
    end
  end

  describe "schema fields" do
    test "has required fields" do
      contact_email = %ContactEmail{}

      assert Map.has_key?(contact_email, :id)
      assert Map.has_key?(contact_email, :email)
      assert Map.has_key?(contact_email, :contact_id)
      assert Map.has_key?(contact_email, :inserted_at)
      assert Map.has_key?(contact_email, :updated_at)
    end

    test "has associations" do
      contact_email = %ContactEmail{}

      assert Map.has_key?(contact_email, :contact)
    end
  end
end
