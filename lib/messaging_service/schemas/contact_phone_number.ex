defmodule MessagingService.Schemas.ContactPhoneNumber do
  @moduledoc """
  Schema for contact phone numbers
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "contact_phone_numbers" do
    field :phone_number, :string

    belongs_to :contact, MessagingService.Schemas.Contact

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.ContactPhoneNumber.t(), map()) :: Ecto.Changeset.t()
  def changeset(contact_phone_number, attrs) do
    contact_phone_number
    |> cast(attrs, [:phone_number, :contact_id])
    |> validate_required([:phone_number, :contact_id])
  end
end
