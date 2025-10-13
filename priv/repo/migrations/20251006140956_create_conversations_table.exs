defmodule MessagingService.Repo.Migrations.CreateConversationsTable do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")

      timestamps()
    end

    create index(:conversations, :inserted_at)
  end
end
