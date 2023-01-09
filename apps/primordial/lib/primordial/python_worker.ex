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

   PythonWorker.call(:my_module, :my_function, my_args) ::

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
  A Task.async GenServer.cast to :python.cast via erlport wrapped inside a
  :poolboy.transaction

  ## Example without :continue callback

   PythonWorker.cast(:my_module, message, _callback) :: :ok

  ## Example with :continue callback
  
   Define your callback function: %{callback: callback, args: []}

   my_callback = fn n -> MyModule.fun(n) end

   callback = %{callback: my_callback, args: [:message, 3]}
   
   PythonWorker.cast(:my_module, message, callback) :: :ok
  
  """
  @spec cast(module :: atom(), message :: term(), callback ::term()) :: :ok
  def cast(module, message, callback \\ %{}) do
    Task.async(fn ->
      :poolboy.transaction(
        :python_worker,
        fn pid ->
          try do
            IO.inspect(pid)
            GenServer.cast(pid, {:cast, %{module: module, message: message, continue: callback}})
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
        continue: nil,
        result: nil,
        pid: pid
      }      
      {:ok, state}
    end
  end

  @impl true
  def handle_call({:call, params}, _from, %{pid: pid} = state) do
    %{module: module, fun: fun, args: args} = params
    result = :python.call(pid, module, fun, [args])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, state}
  end

  @impl true
  def handle_call({:lookup, key}, _from, state) do
    {:reply, Map.fetch(state, key), state}
  end  

  @impl true
  def handle_cast({:cast, params}, %{pid: pid} = state) do
    %{module: module, message: message, continue: continue} = params
    :python.call(pid, module, :register_handler, [self()])
    :python.cast(pid, message)
    Logger.info("[#{__MODULE__}] Handled cast")
    {:noreply, %{state | continue: continue}}
  end

  @impl true  
  def handle_info({:python, message}, %{pid: pid, continue: continue} = state) do
    Logger.info("[#{__MODULE__}] Handled :python info")
    IO.inspect(state)
    IO.inspect(message)
    if !empty_map?(continue) do
      # :continue callback detected
      # Retrieve the :continue callback & args
      %{callback: callback, args: args} = continue
      # Apply the callback function to the arguments
      apply = fn(fun, args) -> fun.(args) end
      result = apply.(callback, args)
      {:noreply, %{state | result: result}, :hibernate}
      # {:stop, :normal, %{state | result: result}}
      # {:noreply, state, {:continue, {:callback, message}}}
       else
         {:stop, :normal, pid}
      end
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.info("[#{__MODULE__}] Handled terminate")
    :ok
  end
  

  # @impl true
  # def handle_continue({:callback, message}, %{continue: continue} = state) do
  #   Logger.info("[#{__MODULE__}] Handled :python continue callback")
  #   IO.inspect(message)
  #   IO.inspect(state)
    
  #   # Retrieve the :continue callback & args
  #   %{callback: callback, args: args} = continue
  #   # Apply the callback function to the arguments
  #   apply = fn(fun, args) -> fun.(args) end
  #   result = apply.(callback, args)

  #   {:noreply, %{state | result: result}}
  # end

  defp empty_map?(map) when map_size(map) == 0, do: true
  defp empty_map?(map) when is_map(map), do: false  
end
