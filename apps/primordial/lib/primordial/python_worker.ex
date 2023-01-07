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

  @timeout 10_000

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

  ## Server callbacks
  
  @impl true
  def init(_) do
    path =
      [:code.priv_dir(:primordial), "python"]
      |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker")
      IO.inspect(pid)
      {:ok, pid}
    end
  end

  @impl true
  def handle_call({:call, params}, _from, pid) do
    %{module: module, fun: fun, args: args} = params
    result = :python.call(pid, module, fun, [args])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end    
end
