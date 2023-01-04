defmodule Primordial.PythonWorker do
  use GenServer
  # https://github.com/martincabrera/python_elixir
  # https://medium.com/stuart-engineering/how-we-use-python-within-elixir-486eb4d266f9
  # https://medium.com/hackernoon/mixing-python-with-elixir-ii-async-e8586f9b2d53
  require Logger

  @timeout 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def call_count(int) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.call(pid, {:count, int})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  def call_dream_studio(prompt) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.call(pid, {:dream_studio, prompt})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end  

  def cast_count(int) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.cast(pid, {:count, int})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  def cast_dream_studio(int) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          GenServer.cast(pid, {:dream_studio, int})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  ## Server callbacks

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
  def handle_call({:count, int}, _from, pid) do
    result = :python.call(pid, :python_message, :count2, [int])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end

  @impl true
  def handle_call({:dream_studio, prompt}, _from, pid) do
    result = :python.call(pid, :dream_studio, :dream_studio_api, [prompt])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end  

  @impl true
  def handle_cast({:count, int}, pid) do
    :python.call(pid, :python_message, :register_handler, [self()])
    message = :python.cast(pid, int)
    {:noreply, message}
  end

  @impl true
  def handle_cast({:dream_studio, int}, pid) do
    :python.call(pid, :dream_studio, :register_handler, [self()])
    message = :python.cast(pid, int)
    Logger.info("[#{__MODULE__}] Handled cast")
    {:noreply, message}
  end  

  @impl true  
  def handle_info({:python, message}, pid) do
    # IO.puts("#{inspect message}")
    IO.inspect(message)
    {:stop, :normal, pid}
  end
end
