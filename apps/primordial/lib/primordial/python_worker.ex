defmodule Primordial.PythonWorker do
  @moduledoc """
  Supervised PythonWorker managed by :poolboy
  
  ## Desc
  GenServer interface for :python via erlport & :poolboy.transaction
  ## Pool
  :python_worker pool of 5 asynchronous workers
  """
  use GenServer

  require Logger

  @timeout 25_000

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
  def call(module, fun, args) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          try do            
            GenServer.call(pid, {:call, %{module: module, fun: fun, args: args}}, @timeout)
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
  @spec cast(module :: atom(), message :: term()) :: :ok
  @spec cast(module :: atom(), message :: term(), dispatch ::term()) :: :ok
  def cast(module, message, dispatch \\ %{}) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          try do
            GenServer.cast(pid, {:cast, %{module: module, message: message, dispatch: dispatch}})
          catch
            e, r ->
            Logger.info("[#{__MODULE__}] GenServer.cast caught error: #{inspect(e)}, #{inspect(r)}")
            Process.exit(pid, :kill)
            {:ok, :error}
          end
       end,
        :infinity
      )
    end) #https://dev.to/felipearaujos/the-power-of-elixir-task-module-54np
    |> Task.await(:infinity)
  end

  def lookup(key) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          try do            
            GenServer.call(pid, {:lookup, key}, @timeout)
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
        dispatch: nil,
        result: nil,
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
    IO.inspect(pid)
    %{module: module, fun: fun, args: args} = params
    result = :python.call(pid, module, fun, args)
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, state}
  end

  @impl true
  def handle_call({:lookup, key}, _from, state) do
    {:reply, Map.fetch(state, key), state}
  end  

  @impl true
  def handle_cast({:cast, params}, %{pid: pid} = state) do
    IO.inspect(pid)
    %{module: module, message: message, dispatch: dispatch} = params
    :python.call(pid, module, :register_handler, [self()])
    :python.cast(pid, message)
    Logger.info("[#{__MODULE__}] Handled cast")
    {:noreply, %{state | dispatch: dispatch}}
  end

  @impl true  
  def handle_info({:python, message}, %{dispatch: dispatch} = state) do
    Logger.info("[#{__MODULE__}] Handled :python info")

    if !empty_map?(dispatch) do
      
      # :dispatch callback detected
      # Retrieve the :dispatch callback & args
      %{module: module, fun: fun, args: args} = dispatch

      # Check for :message inside the args list and replace it with the
      # actually message value coming from :python
      processed_args =
      if :message in args do
        index_list = Enum.with_index(args)
        {_, index} = List.keyfind(index_list, :message, 0)
        List.replace_at(args, index, message)
      else
        args
      end
            
      # Apply the callback function to the arguments
      Logger.info("[#{__MODULE__}] :python handle_info -- dispatched callback")
      # TODO use Register as a dispatcher https://hexdocs.pm/elixir/1.14.2/Registry.html
      result = apply(module, fun, processed_args)

      # Store the result into the current :python_worker state and hibernate
      {:noreply, %{state | result: result}, :hibernate}
       else
         {:noreply, state, :hibernate}
      end
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("[#{__MODULE__}] Handled terminate")
    :ok
  end  

  defp empty_map?(map) when map_size(map) == 0, do: true
  defp empty_map?(map) when is_map(map), do: false  
end
