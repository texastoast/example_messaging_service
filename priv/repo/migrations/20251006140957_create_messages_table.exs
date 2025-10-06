defmodule MessagingService.Repo.Migrations.CreateMessagesTable do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :type, :string
      add :body, :string
      add :attachments, :string, array: true
      add :messaging_provider_id, :string
      add :sent_at, :utc_datetime
      add :received_at, :utc_datetime
      add :conversation_id, references(:conversations, type: :binary_id)
      add :from_number_id, references(:contact_phone_numbers, type: :binary_id)
      add :to_number_id, references(:contact_phone_numbers, type: :binary_id)
      add :from_email_id, references(:contact_emails, type: :binary_id)
      add :to_email_id, references(:contact_emails, type: :binary_id)

      timestamps()
    end
  end
end
