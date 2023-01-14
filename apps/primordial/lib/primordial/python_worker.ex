defmodule Primordial.PythonWorker do
  @moduledoc """
  Supervised PythonWorker managed by :poolboy
  
  ## Desc
  GenServer interface for :python via erlport & :poolboy.transaction
  ## Pool
  :python_worker pool of 5 asynchronous workers
  ## Timeout
  PythonWorker.call/3 @default_timeout 10_000

  PythonWorker.lookup/2 @default_timeout 10_000

  """
  use GenServer

  alias Primordial.AsyncRegistry

  require Logger

  @default_timeout 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  A Task.async GenServer.call to :python.call via erlport wrapped inside a
  :poolboy.transaction

  @default_timeout = 10_000

  ## Example 

   PythonWorker.call(:my_module, :my_function, [arg1, arg2], 10_000) ::

   {:ok,  result} | {:ok, :error}
  
  """
  @spec call(module :: atom(), function :: atom(), args :: list(), timeout ::
  timeout()) :: {:ok, term()} | {:ok, :error}
  def call(module, fun, args, timeout \\ @default_timeout) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
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

  Optional `lookup` argument which can be used to store and associate a message
  received by `handle_info({:python, message})` to the given `lookup` key, your
  python program must reply by casting a message starting with `Atom(b'python')`,
  then this message will stored under your `lookup` key if such key was set by
  the initial PythonWorker.cast/3

  Return `:ok`

  ## Example without lookup

   PythonWorker.cast(:my_module, message) :: :ok

  ## Example with lookup
  
   PythonWorker.cast(:my_module, message, :my_lookup_key) :: :ok

   Now you may read `:my_lookup_key` with the following command:

   result = PythonWorker.lookup(:my_lookup_key, timeout) :: term()

  If the value of `:my_lookup_key` is not yet available, the calling process
  will be automatically subscribed to the topic of `:my_lookup_key` and will
  eventually receive the response or timeout
  
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

  @doc """
  Lookup the async message of the requested `key`

  This lookup value is a `key` which was previously set with
  PythonWorker.cast/3

  Where the lookup key `:my_lookup_key` is a PubSub topic which can be queried for
  future information about an async python task who would reply to
  `handle_info({:python, message})` by casting a message starting with
  `Atom(b'python')`, this message will then be stored under the provided `key`

  If the value of `:my_lookup_key` is not yet available, the calling process
  will be automatically subscribed to the topic of `:my_lookup_key` and will
  eventually receive the response or timeout

  @default_timeout = 10_000

  ## Example

   timeout = 5_000

   result = PythonWorker.lookup(:my_lookup_key, timeout) :: term()

  """

  @spec lookup(key :: atom(), timeout :: timeout()) :: term()
  def lookup(key, timeout \\ @default_timeout) do
    AsyncRegistry.get(key, timeout)
  end

  @doc """
  Returns the current pool status
  """  
  def pool_status() do
    :poolboy.status(:python_worker)
  end
  
  
  ## Server callbacks
  
  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:primordial), "python"]
      |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker instance #{inspect pid}")
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

    # Checkout current worker if cast is expecting an async lookup
    lookup_checkout(lookup)

    {:noreply, %{state | lookup: lookup}}
  end

  @impl true  
  def handle_info({:python, message}, %{pid: pid, lookup: lookup} = state) do
    Logger.info("[#{__MODULE__}] Handled :python info #{inspect pid}")

    # Store message into the AsyncRegistry under the lookup key
    # check the worker back into the process pool
    lookup_checkin(lookup, message)

    {:noreply, %{state | lookup: nil}, :hibernate}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("[#{__MODULE__}] Handled terminate")
    :ok
  end

  defp lookup_checkout(lookup) do
    if !is_nil(lookup), do: (:poolboy.checkout(:python_worker, self());
    Logger.info("[#{__MODULE__}] :poolboy.checkout python_worker: #{inspect self()}"))
  end

  defp lookup_checkin(lookup, message) do
    if !is_nil(lookup), do: (AsyncRegistry.set(lookup, message);
      :poolboy.checkin(:python_worker, self());
      Logger.info("[#{__MODULE__}] :poolboy.checkin python_worker: #{inspect self()}"))    
  end
end
