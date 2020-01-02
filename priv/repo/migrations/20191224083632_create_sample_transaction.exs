defmodule OAuthXYZ.Repo.Migrations.CreateSampleTransaction do
  use Ecto.Migration

  @table :sample_transactions

  def change do
    create table(@table, primary_key: false) do
      add :id, :string, primary_key: true
      add :status, :string, null: false

      add :display, :text
      add :interact, :text
      add :user, :text
      add :resources, :text
      add :keys, :text

      timestamps()
    end
  end
end
