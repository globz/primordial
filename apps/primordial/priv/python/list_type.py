from erlport.erlterms import Atom
from erlport.erlang import set_decoder

# http://erlport.org/docs/python.html#custom-data-types

# Convert Elixir's list to Python Dict

# Activate the decoder for :python.call
# From now one this will decode every value in the
# instance of list and convert them to Python Dict
# Primordial.PythonWorker.call(:list_type, :setup_list_type, [])

# Test the decoder;

# Create a list of arguments
# l = [prompt: "my text", negative_prompt: "my negative prompt", format: "webp"]

# Via PythonWorker.call
# Primordial.PythonWorker.call(:python_test, :testarg2, [l])

# Via PythonWorker.cast
# You must import list_decoder and use it inside handle_message
# Primordial.PythonWorker.cast(:python_test, l, :list)
# Primordial.PythonWorker.lookup(:list)

def setup_list_type():
    set_decoder(list_decoder)
    return Atom(b'ok')

def list_decoder(value):
    if isinstance(value, list):
        value = dict(value)
    return value
