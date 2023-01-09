defmodule Primordial.Simulation.Prediction do
  alias Primordial.PythonWorker

  def count(int, retry \\ 3)
  def count(_arg, _retry = 0), do: :ignore

  def count(int, retry) do
    {:ok, result} = PythonWorker.call(:python_message, :count2, int)
    case result do
      :failed ->
        IO.puts("Simulation task count failed - Retry...!")
        count(int, retry - 1) # We want a clause to match :safe_filter and
        # potentially modify the prompt + :error
      :error -> # This will not match because we simply return :error
        IO.puts("Simulation task caught error - Retry...!")
        count(int, retry - 1)
      _ ->
        IO.puts("Simulation task succeeded!")
        {:ok, result}
    end
  end

  def dream(int, retry \\ 3)
  def dream(_arg, _retry = 0), do: :ignore

  def dream(prompt, retry) do
    {:ok, result} = PythonWorker.call(:dream_studio, :dream_studio_api, prompt)
    case result do
      :safe_filter ->
        IO.puts("Simulation task count failed - Retry...!")
        dream(prompt, retry - 1) # We want a clause to match :safe_filter and
        # potentially modify the prompt
      :error ->
        IO.puts("Simulation task caught error - Retry...!")
        dream(prompt, retry - 1)
      _ ->
        IO.puts("Simulation task succeeded!")
        # return image filename + path
        # Another function convert_to_webp will take this result and convert
        # the image, then another function will log the output to the database
        {:ok, result}
    end
  end

  def test(int) do
    int + 2
  end
  
end
