defmodule Primordial.PythonWorker do
  @moduledoc """
  Supervised PythonWorker managed by :poolboy
  
  ## Desc
  GenServer interface for :python via erlport & :poolboy.transaction
  ## Pool
  :python_worker pool of 5 asynchronous workers
  """
  use GenServer

  alias Primordial.AsyncRegistry

  require Logger

  @default_timeout 25_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  A Task.async GenServer.call to :python.call via erlport wrapped inside a
  :poolboy.transaction

  ## Example 

   PythonWorker.call(:my_module, :my_function, [arg1, arg2]) ::

   {:ok,  result} | {:ok, :error}
  
  """
  @spec call(module :: atom(), function :: atom(), args :: any()) :: result :: atom()
  def call(module, fun, args, timeout \\ @default_timeout) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          IO.inspect(pid)
          try do            
            GenServer.call(pid, {:call, %{module: module, fun: fun, args: args}}, timeout)
          catch
            e, r ->
            Logger.info("[#{__MODULE__}] GenServer.call caught error: #{inspect(e)}, #{inspect(r)}")
            Process.exit(pid, :kill)
            {:ok, :error}
          end
       end,
        :infinity
      )
    end)
    |> Task.await(:infinity)
  end

  @doc """
  A Task.async GenServer.cast to `:python.cast` via erlport wrapped inside a
  `:poolboy.transaction`

  Sends an asynchronous request to the :python instance of :my_module

  Optional `lookup` argument which can be used to store a message
  received by handle_info({:python, message})

  Return `:ok`

  ## Example without lookup

   PythonWorker.cast(:my_module, message) :: :ok

  ## Example with lookup
  
   PythonWorker.cast(:my_module, message, :result) :: :ok
  
  """
  @spec cast(module :: atom(), message :: term()) :: :ok
  @spec cast(module :: atom(), message :: term(), lookup :: atom()) :: :ok
  def cast(module, message, lookup \\ nil) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          try do
            GenServer.cast(pid, {:cast, %{module: module, message: message, lookup: lookup}})
          catch
            e, r ->
            Logger.info("[#{__MODULE__}] GenServer.cast caught error: #{inspect(e)}, #{inspect(r)}")
            Process.exit(pid, :kill)
            {:ok, :error}
          end
       end,
        :infinity
      )
    end)
    |> Task.await(:infinity)
  end

  def lookup(key, timeout \\ @default_timeout) do
    AsyncRegistry.get(key, timeout)
  end
  
  ## Server callbacks
  
  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:primordial), "python"]
      |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker #{inspect pid}")
      state = %{
        lookup: nil,
        pid: pid
      }
      {:ok, state}
    end
  end

  @impl true
  def handle_call({:call, params}, _from, %{pid: pid} = state) do
    %{module: module, fun: fun, args: args} = params
    result = :python.call(pid, module, fun, args)
    Logger.info("[#{__MODULE__}] Handled call #{inspect pid}")
    {:reply, {:ok, result}, state}
  end

  @impl true
  def handle_cast({:cast, params}, %{pid: pid} = state) do
    %{module: module, message: message, lookup: lookup} = params
    :python.call(pid, module, :register_handler, [self()])
    :python.cast(pid, message)
    Logger.info("[#{__MODULE__}] Handled cast #{inspect pid}")

    # Check out current worker if cast is expecting an async lookup
    lookup_checkout(lookup, pid)
    
    {:noreply, %{state | lookup: lookup}}
  end

  @impl true  
  def handle_info({:python, message}, %{pid: pid, lookup: lookup} = state) do
    Logger.info("[#{__MODULE__}] Handled :python info #{inspect pid}")

    # Store message into the AsyncRegistry under the lookup key
    # check the worker back into the process pool
    lookup_checkin(lookup, message, pid)

    {:noreply, %{state | lookup: nil}, :hibernate}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("[#{__MODULE__}] Handled terminate")
    :ok
  end

  defp lookup_checkout(lookup, pid) do
    if !is_nil(lookup), do: :poolboy.checkout(:python_worker, pid)
  end

  defp lookup_checkin(lookup, message, pid) do
    if !is_nil(lookup), do: (AsyncRegistry.set(lookup, message);
      :poolboy.checkin(:python_worker, pid))
  end
end
