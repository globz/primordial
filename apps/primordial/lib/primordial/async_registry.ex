defmodule Primordial.AsyncRegistry do
  use GenServer
  @default_timeout 1_000
  @registry Primordial.Registry.PubSub 
  
  def set(key, value),
    do: GenServer.cast(__MODULE__, {:set, key, value})
    
  def get(key, timeout \\ @default_timeout) do
    case GenServer.call(__MODULE__, {:get, key}) do
      {:wait, registry, topic} -> wait(registry, topic, timeout)
      value -> value
    end
  end
  
  defp wait(registry, topic, timeout) do
    Registry.register(registry, topic, [])
    receive do
      {:broadcast, value} -> value
    after timeout ->
      {:error, :timeout}
    end
  end
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
      
  def init(_opts) do
    {:ok, %{}}
  end
  
  def handle_call({:get, key}, _from, state) do
    reply = Map.get(state, key, {:wait, @registry, key})
    {:reply, reply, state}
  end
  
  def handle_cast({:set, key, value}, state) do
    broadcast(key, value)
    {:noreply, Map.put(state, key, value)}
  end
  
  defp broadcast(key, value) do
    Registry.dispatch(@registry, key, fn(entries) ->
      for {pid, _} <- entries, do: send(pid, {:broadcast, value})
    end)
  end
end
