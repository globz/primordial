defmodule Primordial.PythonWorker do
  use GenServer

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
  def handle_call({:dream_studio, prompt}, _from, pid) do
    result = :python.call(pid, :dream_studio, :dream_studio_api, [prompt])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end  


  # If the task fails...
  @impl true
  def handle_info({:DOWN, _ref, _, _, reason}, state) do
    IO.puts "Task failed with reason #{inspect(reason)}"
    {:noreply, state}
  end
end
