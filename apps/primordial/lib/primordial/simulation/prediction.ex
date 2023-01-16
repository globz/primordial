defmodule Primordial.Simulation.Prediction do
  alias Primordial.PythonWorker

  require Logger

  def dream(int, retry \\ 3)
  def dream(_arg, _retry = 0), do: :ignore

  def dream(prompt, retry) do
    PythonWorker.cast(:dream_studio, prompt, :dream)
    case PythonWorker.lookup(:dream, 25_000) do
      {:error, :timeout} ->
        Logger.info("[#{__MODULE__}] timeout")
        # Increase timeout by +5_000?
      {:ok, :safe_filter} ->
        Logger.info("[#{__MODULE__}] triggered safe_filter")
        # Modify negative prompt?
      {:ok, result} ->
        Logger.info("[#{__MODULE__}] sweet dreams! #{inspect result}")
        convert_to_webp()
        {:ok, result}
    end
  end

  def convert_to_webp() do
    # This should convert one or image from dream...just in case
    # TODO fix image not converting, perhaps not saving in the proper
    # directory, when BEAM is restart the command will work.
    # https://github.com/WannesFransen1994/phoenix-dynamic-images
    # https://github.com/WannesFransen1994/phoenix-dynamic-images/blob/master/apps/dynamic_images/lib/dynamic_images/schemas/image.ex
    # Convert image(s) to webp
    PythonWorker.cast(:convert_to_webp, nil, :dream_webp)
    PythonWorker.lookup(:dream_webp)
  end

  # def build do
  #   # this would be prompt_crafting()
  #   prompt = "A rendering of a dormant universe, awaiting to breed a new life"
  #   # Pipe both commands feeding result into convert_to_webp inside the with/do
  #   with {:ok, result} <- dream(prompt) |> convert_to_webp do
  #     IO.puts("Save image/path to DB")
  #   end    
  # end
  
  
end


    # {:ok, result} = PythonWorker.call(:dream_studio, :dream_studio_api, prompt)
    # case result do
    #   :safe_filter ->
    #     IO.puts("Simulation task count failed - Retry...!")
    #     dream(prompt, retry - 1) # We want a clause to match :safe_filter and
    #     # potentially modify the prompt
    #   :error ->
    #     IO.puts("Simulation task caught error - Retry...!")
    #     dream(prompt, retry - 1)
    #   _ ->
    #     IO.puts("Simulation task succeeded!")
    #     # return image filename + path
    #     # Another function convert_to_webp will take this result and convert
    #     # the image, then another function will log the output to the database
    #     {:ok, result}
    # end
