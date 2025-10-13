defmodule MessagingService.Repo.Migrations.CreateContactsTable do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string

      timestamps()
    end

    create index(:contacts, [:name])
    create index(:contacts, [:inserted_at])
  end
end
