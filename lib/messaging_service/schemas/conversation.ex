defmodule MessagingService.Schemas.Conversation do
  @moduledoc """
  Schema for conversations
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "conversations" do
    has_many :messages, MessagingService.Schemas.Message
    belongs_to :from_contact, MessagingService.Schemas.Contact
    belongs_to :to_contact, MessagingService.Schemas.Contact

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.Conversation.t(), map()) :: Ecto.Changeset.t()
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:from_contact_id, :to_contact_id])
    |> validate_required([:from_contact_id, :to_contact_id])
  end
end
