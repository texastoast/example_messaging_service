defmodule MessagingService.Repo.Migrations.CreateContactPhoneNumbersTable do
  use Ecto.Migration

  def change do
    create table(:contact_phone_numbers, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :number, :string
      add :contact_id, references(:contacts, type: :binary_id)

      timestamps()
    end
  end
end
