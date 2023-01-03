defmodule Primordial.PythonServer do
  use GenServer

  alias Primordial.PythonHelper

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    path = [:code.priv_dir(:primordial), "python"]
    |> Path.join()
    |> to_charlist()

    with {:ok, pid} <- PythonHelper.start_instance(path, 'python3') do
      {:ok, pid}
    end
  end
  
  def call_function(module, function, args) do
    GenServer.call(__MODULE__, {:call_function, module, function, args})
  end

  def cast_function(message) do
    GenServer.cast(__MODULE__, {:cast_function, message})
  end

  def handle_call({:call_function, module, function, args}, _from, pid) do
    result = PythonHelper.call_instance(pid, module, function, args)
    {:reply, result, pid}
  end

  def handle_cast({:cast_function, message}, pid) do
    PythonHelper.cast_instance(pid, message)
    {:noreply, pid}
  end

  def handle_info({:python, message}, pid) do
    IO.puts("Received message from python: #{inspect message}")
    {:noreply, pid}
  end

  def terminate(_reason, pid) do
    PythonHelper.stop_instance(pid)
    :ok
  end
  
end
