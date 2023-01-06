defmodule Primordial.PythonWorker do
  use GenServer
  # https://hexdocs.pm/elixir/1.14.2/GenServer.html#module-client-server-apis
  require Logger

  @timeout 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # def call_dream_studio(prompt) do
  #   Task.async(fn ->
  #     :poolboy.transaction(
  #       :python_worker,
  #       fn pid ->
  #         GenServer.call(pid, {:dream_studio, prompt})
  #       end,
  #       @timeout
  #     )
  #   end)
  #   |> Task.await(@timeout)
  # end

  def call_dream_studio(prompt) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        try do
          fn pid ->
            GenServer.call(pid, {:dream_studio, prompt}, @timeout)          
          end
        catch
          :exit, {:timeout, {GenServer, :call, _}} -> {:error, :timeout}
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  def call_count(int) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        try do
          fn pid ->
            GenServer.call(pid, {:count, int}, @timeout)          
          end
        catch
          :exit, {:timeout, {GenServer, :call, _}} -> {:error, :timeout}
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end  

  ## Server callbacks
  
  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:primordial), "python"]
      |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker")
      IO.inspect(pid)
      state = %{
        arg: [],
        pid: pid
      }
      IO.inspect(state)
      {:ok, state}
    end
  end

  @impl true
  def handle_call({:dream_studio, prompt}, _from, pid) do
    result = :python.call(pid, :dream_studio, :dream_studio_api, [prompt])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end

  @impl true
  def handle_call({:count, int}, _from, %{pid: pid} = state) do
    :python.call(pid, :python_message, :register_handler, [self()])
    result = :python.call(pid, :python_message, :count2, [int])
    Logger.info("[#{__MODULE__}] Handled call")
    IO.inspect(pid)
    state = %{state | arg: int}
    IO.inspect(state)    
    {:reply, {:ok, result}, %{state | pid: pid}}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end  

  # A python function failed, store the current function args inside the state
  # and :stop the worker
  # Will need a get state function
  # https://elixirschool.com/blog/til-genserver-handle-continue/
  # https://dockyard.com/blog/2019/04/02/three-simple-patterns-for-retrying-jobs-in-elixir
  @impl true  
  def handle_info({:python, message}, pid) do
    Logger.info("[#{__MODULE__}] Handled info")
    #IO.inspect(message)
    IO.puts("Received message from python: #{inspect message}")
    IO.inspect(pid)
    # {:noreply, pid}
    # {:noreply, pid, {:continue, :retry}}
    {:stop, :normal, pid}
  end

  # Send the state here, put pid & args & current function inside the state
  # @impl true
  # def handle_continue(:retry, pid) do
  #   IO.puts("Task failed, restarting current task...")
  #   IO.inspect(pid)
  #   #:python.stop(pid)
  #   #call_count(1)
  #   #:poolboy.checkin(:python_worker, pid)
  #   worker = :poolboy.checkout(:python_worker, pid)
  #   IO.puts("Checked out this worker...")
  #   IO.inspect(worker)
  #   :poolboy.checkin(:python_worker, worker)
  #   Task.async(call_count(1)) |> Task.await(@timeout)
  #   #GenServer.call(worker, {:count, 1}, @timeout)
  #   {:noreply, pid, @timeout}
  # end  
end
