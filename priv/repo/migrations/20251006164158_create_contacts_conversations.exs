defmodule MessagingService.Repo.Migrations.CreateContactsConversations do
  use Ecto.Migration

  def change do
    create table(:contacts_conversations, primary_key: false) do
      add :contact_id, references(:contacts, type: :binary_id)
      add :conversation_id, references(:conversations, type: :binary_id)
    end

    create unique_index(:contacts_conversations, [:contact_id, :conversation_id])
  end
end
