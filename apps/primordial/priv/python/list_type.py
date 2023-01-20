from erlport.erlterms import Atom
from erlport.erlang import set_decoder

# http://erlport.org/docs/python.html#custom-data-types

# Convert Elixir's list to Python Dict
# Example;

# Activate the decoder - from now one this will decode every value in the
# instance of list
# Primordial.PythonWorker.call(:list_type, :setup_list_type, [])

# Test the decoder;

# Create a list of arguments
# l = [prompt: "my text", negative_prompt: "my neg prompt", format: "webp"]

# Via PythonWorker.call
# Primordial.PythonWorker.call(:python_message, :testarg2, [l])

# Via PythonWorker.cast
# Primordial.PythonWorker.cast(:python_message, l, :list)
# Primordial.PythonWorker.lookup(:list)


# TODO:
# Test if this works with message casting
# Looks like we can activate the decoder and use cast
# However the decoder does not match on isinstance(value, list)
# It is not the same date structure
# ** (stop) {:python, :"builtins.AttributeError", '\'OpaqueObject\' object has no
# attribute \'message\'', ['  File
# "/home/globz/Dropbox/Projects/Elixir/primordial/_build/dev/lib/primordial/priv/python/list_type.py",
# line 41, in list_decoder\n 
# I believe it may have to be done inside set_message_handler(handle_message)

def setup_list_type():
    set_decoder(list_decoder)
    return Atom(b'ok')

# def list_decoder(value):
#     arg_list = []
#     # Append each key/value pair as tuple to the list
#     for i in range(len(value.message)):
#         arg_list.append((value.message[i]))

#     # Create dict from list ~ dict([('key', value), ('key1', value), ('key2', value)])
#     value = dict(arg_list)
#     return value

def list_decoder(value):
    if isinstance(value, list):
        arg_list = []
        # Append each key/value pair as tuple to the list
        for i in range(len(value)):
            arg_list.append((value[i]))

        # Create dict from list ~ dict([('key', value), ('key1', value), ('key2', value)])
        value = dict(arg_list)
    return value

