defmodule MessagingService.Schemas.ConversationTest do
  @moduledoc """
  Tests for the MessagingService.Schemas.Conversation module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Schemas.Conversation

  describe "changeset/2" do
    test "valid changeset with empty attributes" do
      attrs = %{}

      changeset = Conversation.changeset(%Conversation{}, attrs)

      assert changeset.valid?
      assert changeset.changes == %{}
    end

    test "valid changeset with empty map" do
      changeset = Conversation.changeset(%Conversation{}, %{})

      assert changeset.valid?
      assert changeset.changes == %{}
    end

    test "ignores unknown attributes" do
      attrs = %{unknown_field: "should be ignored", another_field: "also ignored"}

      changeset = Conversation.changeset(%Conversation{}, attrs)

      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :unknown_field)
      refute Map.has_key?(changeset.changes, :another_field)
    end

    test "changeset is always valid since no validations are required" do
      test_cases = [
        %{},
        %{some_field: "value"},
        %{field1: "value1", field2: "value2"}
      ]

      for attrs <- test_cases do
        changeset = Conversation.changeset(%Conversation{}, attrs)
        assert changeset.valid?, "Changeset should be valid for attrs: #{inspect(attrs)}"
      end
    end
  end

  describe "schema fields" do
    test "has required fields" do
      conversation = %Conversation{}

      assert Map.has_key?(conversation, :id)
      assert Map.has_key?(conversation, :inserted_at)
      assert Map.has_key?(conversation, :updated_at)
    end

    test "has associations" do
      conversation = %Conversation{}

      assert Map.has_key?(conversation, :messages)
      assert Map.has_key?(conversation, :contacts)
    end
  end

  describe "schema structure" do
    test "conversation struct is properly defined" do
      conversation = %Conversation{}

      # Verify the struct is a Conversation
      assert %Conversation{} = conversation
    end

    test "conversation can be created with default values" do
      conversation = %Conversation{}

      # All fields should be nil by default
      assert conversation.id == nil
      assert conversation.inserted_at == nil
      assert conversation.updated_at == nil
      # Associations are Ecto.Association.NotLoaded by default
      assert %Ecto.Association.NotLoaded{} = conversation.messages
      assert %Ecto.Association.NotLoaded{} = conversation.contacts
    end
  end
end
