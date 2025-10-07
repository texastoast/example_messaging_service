defmodule MessagingService.Schemas.ContactTest do
  @moduledoc """
  Tests for the MessagingService.Schemas.Contact module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Schemas.Contact

  describe "changeset/2" do
    test "valid changeset with valid attributes" do
      attrs = %{name: "John Doe"}

      changeset = Contact.changeset(%Contact{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "John Doe"
    end

    test "invalid changeset without required name" do
      attrs = %{}

      changeset = Contact.changeset(%Contact{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "invalid changeset with empty name" do
      attrs = %{name: ""}

      changeset = Contact.changeset(%Contact{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "invalid changeset with nil name" do
      attrs = %{name: nil}

      changeset = Contact.changeset(%Contact{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "valid changeset with long name" do
      attrs = %{name: String.duplicate("A", 255)}

      changeset = Contact.changeset(%Contact{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == String.duplicate("A", 255)
    end

    test "ignores unknown attributes" do
      attrs = %{name: "John Doe", unknown_field: "should be ignored"}

      changeset = Contact.changeset(%Contact{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "John Doe"
      refute Map.has_key?(changeset.changes, :unknown_field)
    end
  end

  describe "schema fields" do
    test "has required fields" do
      contact = %Contact{}

      assert Map.has_key?(contact, :id)
      assert Map.has_key?(contact, :name)
      assert Map.has_key?(contact, :inserted_at)
      assert Map.has_key?(contact, :updated_at)
    end

    test "has associations" do
      contact = %Contact{}

      assert Map.has_key?(contact, :contact_emails)
      assert Map.has_key?(contact, :contact_phone_numbers)
      assert Map.has_key?(contact, :conversations)
    end
  end
end
