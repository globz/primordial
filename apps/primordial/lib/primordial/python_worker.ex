defmodule Primordial.PythonWorker do
  use GenServer
  # https://github.com/martincabrera/python_elixir
  # https://medium.com/stuart-engineering/how-we-use-python-within-elixir-486eb4d266f9
  # https://medium.com/hackernoon/mixing-python-with-elixir-ii-async-e8586f9b2d53
  require Logger

  @timeout 10_000

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def message(pid, my_string) do
    GenServer.call(pid, {:hello, my_string})
  end

  def call(my_string) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.call(pid, {:hello, my_string})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  #############
  # Callbacks #
  #############

  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:primordial), "python"]
      |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker")
      {:ok, pid}
    end
  end

  @impl true
  def handle_call({:hello, my_string}, _from, pid) do
    result = :python.call(pid, :python_message, :hello, [my_string])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end
end
