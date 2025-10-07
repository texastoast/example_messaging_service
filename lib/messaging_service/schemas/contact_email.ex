defmodule MessagingService.Schemas.ContactEmail do
  @moduledoc """
  Schema for contact emails
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "contact_emails" do
    field :email, :string

    belongs_to :contact, MessagingService.Schemas.Contact

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.ContactEmail.t(), map()) :: Ecto.Changeset.t()
  def changeset(contact_email, attrs) do
    contact_email
    |> cast(attrs, [:email, :contact_id])
    |> validate_required([:email, :contact_id])
  end
end
