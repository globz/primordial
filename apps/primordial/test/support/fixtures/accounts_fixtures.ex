defmodule Primordial.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Primordial.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        id_card: 42,
        name: "some name"
      })
      |> Primordial.Accounts.create_user()

    user
  end
end
