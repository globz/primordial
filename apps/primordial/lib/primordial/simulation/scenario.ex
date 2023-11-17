defmodule Primordial.Simulation.Scenario do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Scenario's internal representation

  Scenario's are fundamental building block. They describe events which are
  to be randomly injected into the Simulation.    
  """

  defstruct [:id, :name, :description, :prompts, :content, :depend_on]

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          description: String.t(),
          prompts: map(),
          content: String.t(),
          depend_on: integer()
        }

  def new(opts \\ []) do
    Enum.reduce(opts, %__MODULE__{}, &put_opt/2)
  end

  defp put_opt(opt, acc)

  defp put_opt({:id, id}, acc) when is_integer(id) do
    %{acc | id: id}
  end

  defp put_opt({:name, name}, acc) when is_binary(name) do
    %{acc | name: name}
  end

  defp put_opt({:description, description}, acc) when is_binary(description) do
    %{acc | description: description}
  end

  defp put_opt({:prompts, prompts}, acc) when is_map(prompts) do
    %{acc | prompts: prompts}
  end

  defp put_opt({:content, content}, acc) when is_binary(content) do
    %{acc | content: content}
  end

  defp put_opt({:depend_on, depend_on}, acc) when is_integer(depend_on) do
    %{acc | depend_on: depend_on}
  end

  defp put_opt(_opt, acc) do
    acc
  end
end
