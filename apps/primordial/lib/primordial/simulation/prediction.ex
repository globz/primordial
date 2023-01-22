defmodule Primordial.Simulation.Prediction do
  alias Primordial.PythonWorker

  require Logger

  @default_timeout 25_000

  def dream(int, retry \\ 3, timeout \\ @default_timeout)
  def dream(_arg, _retry = 0, _timeout), do: :ignore

  def dream(config, retry, timeout) do
    PythonWorker.cast(:dream_studio, config, :dream, timeout)
    case PythonWorker.lookup(:dream, timeout) do
      {:error, :timeout} ->
        Logger.info("[#{__MODULE__}] Timeout")
        # Increase each timeout by 5000 for a max run time of 35_000
        dream(config, retry - 1, timeout + 5000) 
      {:ok, :safe_filter} ->
        Logger.info("[#{__MODULE__}] Triggered safe_filter")
        # Modify negative prompt?
      {:ok, result} ->
        Logger.info("[#{__MODULE__}] Zzz!")
        {:ok, result}
    end
  end

  def build do
    # this would be the output of prompt_crafting()
    # This path should be referred as @dreams and part of the app config
    dream_config = [
      prompt: "A rendering of a dormant universe, awaiting to breed a new life",
      path: "apps/primordial_web/priv/static/images/simulation",
      format: "webp"
    ]
    
    with {:ok, result} <- dream(dream_config) do
      IO.puts("with result  #{result}")
    end    
  end  
end
