defmodule MessagingService.Schemas.Conversation do
  @moduledoc """
  Schema for conversations
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "conversations" do
    has_many :messages, MessagingService.Schemas.Message

    many_to_many :contacts, MessagingService.Schemas.Contact,
      join_through: "contacts_conversations"

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.Conversation.t(), map()) :: Ecto.Changeset.t()
  def changeset(conversation, attrs \\ %{}) do
    conversation
    |> cast(attrs, [])
  end
end
