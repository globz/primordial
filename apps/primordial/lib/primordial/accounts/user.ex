defmodule Primordial.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  
  schema "users" do
    field :id_card, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id_card, :name])
    |> validate_required([:name])
    |> validate_required([:id_card])
    |> unique_constraint(:id_card,
    name: "users_id_card_index",
    message: "id card already exists. Please log in."
    )
    |> unique_constraint(:name,
    name: "users_name_index",
    message: "Name already in use. Please use another."
    )
  end
end
