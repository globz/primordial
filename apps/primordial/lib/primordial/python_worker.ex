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

  Optional `dispatch` argument which can be used to dispatch a message
  received by handle_info({:python, message}) to another Elixir module

  Return `:ok`

  ## Example without dispatch

   PythonWorker.cast(:my_module, message) :: :ok

  ## Example with dispatch
  
   dispatch = %{module: MyModule, fun: :my_fun, args: [arg1, arg2]}

   PythonWorker.cast(:my_module, message, dispatch) :: :ok

  ## Example with dispatch & :message argument

  dispatch = %{module: MyModule, fun: :my_fun, args: [`:message`, arg2]}

  PythonWorker.cast(:my_module, message, dispatch) :: :ok

  This will effectively replace `:message` with the actual message received
  by handle_info({:python, message}) and will dispatched it to the assigned
  dispatch module, along with any other arguments.

  The dispatch result is automatically added to the current :python_worker
  state and can be accessed via PythonWorker.lookup(:result)
  
  """
  #@spec cast(module :: atom(), message :: term()) :: :ok
  #@spec cast(module :: atom(), message :: term(), dispatch ::term()) :: :ok
  def cast(module, message, lookup \\ nil) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          IO.inspect(pid)
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
      # :poolboy only use one worker when multiple calls are made, should state
      # be a list?
      # http://www.davekuhlman.org/elixir-poolboy-erlport-datasci.html
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
    IO.inspect(pid)
    %{module: module, message: message, lookup: lookup} = params
    :python.call(pid, module, :register_handler, [self()])
    :python.cast(pid, message)
    Logger.info("[#{__MODULE__}] Handled cast #{inspect pid}")
    :poolboy.checkout(:python_worker, pid)
    {:noreply, %{state | lookup: lookup}}
  end

  @impl true  
  def handle_info({:python, message}, %{pid: pid, lookup: lookup} = state) do
    Logger.info("[#{__MODULE__}] Handled :python info #{inspect pid}")
    IO.inspect(lookup)
    # Lookup key detected
    # Store the result into the AsyncRegistry
    if !is_nil(lookup), do: AsyncRegistry.set(lookup, message)

    {:noreply, %{state | lookup: nil}, :hibernate}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("[#{__MODULE__}] Handled terminate")
    :ok
  end
end

# TODO

# Investigate why poolboy only use one worker
# Fix lookup key being overwritten, should track it with make_ref and python
# message should send back the ref along with the result
# or checkout workers on cast and re-enable them when a message is
# received....however if no response is expected then do not checkout the
# worker, then simply check back the worker once the response is received!
