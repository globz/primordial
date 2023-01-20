defmodule Primordial.Simulation.Prediction do
  alias Primordial.PythonWorker

  require Logger

  def dream(int, retry \\ 3)
  def dream(_arg, _retry = 0), do: :ignore

  def dream(config, retry) do
    PythonWorker.cast(:dream_studio, config, :dream)
    case PythonWorker.lookup(:dream, 25_000) do
      {:error, :timeout} ->
        Logger.info("[#{__MODULE__}] Timeout")
        # Increase timeout by +5_000?
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
      IO.puts(result)
    end    
  end  
end
