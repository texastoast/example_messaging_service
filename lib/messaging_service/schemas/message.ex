defmodule MessagingService.Schemas.Message do
  @moduledoc """
  Schema for messages
  """
  use MessagingService.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @derive {Jason.Encoder,
           only: [
             :id,
             :type,
             :body,
             :attachments,
             :messaging_provider_id,
             :conversation_id,
             :from_number_id,
             :to_number_id,
             :from_email_id,
             :to_email_id
           ]}

  schema "messages" do
    field :type, Ecto.Enum, values: [:sms, :mms, :email]
    field :body, :string
    field :attachments, {:array, :string}
    field :messaging_provider_id, :string

    belongs_to :conversation, MessagingService.Schemas.Conversation
    belongs_to :from_number, MessagingService.Schemas.ContactPhoneNumber
    belongs_to :to_number, MessagingService.Schemas.ContactPhoneNumber
    belongs_to :from_email, MessagingService.Schemas.ContactEmail
    belongs_to :to_email, MessagingService.Schemas.ContactEmail

    timestamps()
  end

  @spec changeset(MessagingService.Schemas.Message.t(), map()) :: Ecto.Changeset.t()
  def changeset(message, attrs) do
    message
    |> cast(attrs, [
      :type,
      :body,
      :attachments,
      :messaging_provider_id,
      :conversation_id,
      :from_number_id,
      :to_number_id,
      :from_email_id,
      :to_email_id
    ])
    |> validate_required([:type, :body, :conversation_id])
    |> validate_contact_methods()
  end

  defp validate_contact_methods(changeset) do
    from_number = get_field(changeset, :from_number_id)
    to_number = get_field(changeset, :to_number_id)
    from_email = get_field(changeset, :from_email_id)
    to_email = get_field(changeset, :to_email_id)

    cond do
      from_number && to_number ->
        changeset

      from_email && to_email ->
        changeset

      true ->
        add_error(
          changeset,
          :contact_methods,
          "must provide either from/to phone numbers or from/to email addresses"
        )
    end
  end
end
