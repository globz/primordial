defmodule Primordial.Simulation do
  alias Primordial.PythonWorker

  def count(int) do
    {:ok, result} = PythonWorker.call_count(int)

    case result do
      :failed ->
        IO.puts("Simulation task count failed!")
      _ ->
        IO.puts("Simulation task succeeded!")
        IO.inspect(result)
    end    
  end
    
end
