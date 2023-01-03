from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom

message_handler = None

def cast_message(pid, message):
 cast(pid, (Atom(b'python', result)))

def register_handler(pid):
 global message_handler
 message_handler = pid
 
def handle_message(message):
 print("Received message from Elixir")
 print(message)
 if message_handler:
  result = welcome(message)     
  cast_message(message_handler, result)

def welcome(world):
 return "".join(["Hello", " ", world.decode("utf-8")])

set_message_handler(handle_message)
