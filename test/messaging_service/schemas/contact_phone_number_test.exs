defmodule MessagingService.Schemas.ContactPhoneNumberTest do
  @moduledoc """
  Tests for the MessagingService.Schemas.ContactPhoneNumber module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Schemas.ContactPhoneNumber
  import MessagingService.Fixtures

  describe "changeset/2" do
    test "valid changeset with valid attributes" do
      contact = contact_fixture()
      attrs = %{number: "+1234567890", contact_id: contact.id}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      assert changeset.valid?
      assert changeset.changes.number == "+1234567890"
      assert changeset.changes.contact_id == contact.id
    end

    test "invalid changeset without required number" do
      contact = contact_fixture()
      attrs = %{contact_id: contact.id}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).number
    end

    test "invalid changeset without required contact_id" do
      attrs = %{number: "+1234567890"}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).contact_id
    end

    test "invalid changeset with empty number" do
      contact = contact_fixture()
      attrs = %{number: "", contact_id: contact.id}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).number
    end

    test "invalid changeset with nil number" do
      contact = contact_fixture()
      attrs = %{number: nil, contact_id: contact.id}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).number
    end

    test "invalid changeset with nil contact_id" do
      attrs = %{number: "+1234567890", contact_id: nil}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).contact_id
    end

    test "valid changeset with various phone number formats" do
      contact = contact_fixture()

      valid_numbers = [
        "+1234567890",
        "1234567890",
        "+1-234-567-8900",
        "(123) 456-7890",
        "123.456.7890",
        "+44 20 7946 0958"
      ]

      for number <- valid_numbers do
        attrs = %{number: number, contact_id: contact.id}
        changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)
        assert changeset.valid?, "Phone number #{number} should be valid"
      end
    end

    test "ignores unknown attributes" do
      contact = contact_fixture()
      attrs = %{number: "+1234567890", contact_id: contact.id, unknown_field: "should be ignored"}

      changeset = ContactPhoneNumber.changeset(%ContactPhoneNumber{}, attrs)

      assert changeset.valid?
      assert changeset.changes.number == "+1234567890"
      assert changeset.changes.contact_id == contact.id
      refute Map.has_key?(changeset.changes, :unknown_field)
    end
  end

  describe "schema fields" do
    test "has required fields" do
      contact_phone_number = %ContactPhoneNumber{}

      assert Map.has_key?(contact_phone_number, :id)
      assert Map.has_key?(contact_phone_number, :number)
      assert Map.has_key?(contact_phone_number, :contact_id)
      assert Map.has_key?(contact_phone_number, :inserted_at)
      assert Map.has_key?(contact_phone_number, :updated_at)
    end

    test "has associations" do
      contact_phone_number = %ContactPhoneNumber{}

      assert Map.has_key?(contact_phone_number, :contact)
    end
  end
end
