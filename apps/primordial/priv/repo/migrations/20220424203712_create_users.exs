defmodule Primordial.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :id_card, :integer
      add :name, :string

      timestamps()
    end
    
    create unique_index(:users, :id_card)
    create unique_index(:users, :name)
  end

end
