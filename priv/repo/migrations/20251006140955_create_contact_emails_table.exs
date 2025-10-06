defmodule MessagingService.Repo.Migrations.CreateContactEmailsTable do
  use Ecto.Migration

  def change do
    create table(:contact_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :email, :string
      add :contact_id, references(:contacts, type: :binary_id)

      timestamps()
    end
  end
end
