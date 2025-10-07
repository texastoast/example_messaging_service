defmodule MessagingService.Schemas.Contact do
  @moduledoc """
  Schema for contacts
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "contacts" do
    field :name, :string

    has_many :contact_emails, MessagingService.Schemas.ContactEmail
    has_many :contact_phone_numbers, MessagingService.Schemas.ContactPhoneNumber

    many_to_many :conversations, MessagingService.Schemas.Conversation,
      join_through: "contacts_conversations"

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.Contact.t(), map()) :: Ecto.Changeset.t()
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
