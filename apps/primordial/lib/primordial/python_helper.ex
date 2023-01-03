defmodule Primordial.PythonHelper do

  def start_instance(path, version \\ 'python') do
    :python.start([{:python_path, path}, {:python, version}])
  end  

  def call_instance(pid, module, function, args \\ []) do
    :python.call(pid, module, function, args)
  end

  def cast_instance(pid, message) do
    :python.cast(pid, message)
  end  

  def stop_instance(pid) do
    :python.stop(pid)
  end

end
