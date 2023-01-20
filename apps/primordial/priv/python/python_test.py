from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom
from list_type import list_decoder
import time
import sys

message_handler = None

def cast_message(pid, result):
 cast(pid, (Atom(b'python'), result))
 
def register_handler(pid):
 global message_handler
 message_handler = pid
 
def handle_message(message):
 if message_handler:
  message = list_decoder(message)
  result = testarg2(message)
  cast_message(message_handler, result)

def hello(my_string):
  if isinstance(my_string, bytes):
    my_string = my_string.decode("utf-8")
  
  return "Hello world from " + my_string

def hello2(my_string, my_string2):
  if isinstance(my_string, bytes):
    my_string = my_string.decode("utf-8")
    my_string2 = my_string2.decode("utf-8")
  
  return "Hello world from " + my_string + my_string2

def count(count=100):
  #simluate a time consuming python function
  i = 0
  data = []
  while i < count:
    time.sleep(1)
    data.append(i+1)
    i = i + 1
  return data

def testarg(arg):
 dict1 = dict([(arg[0]), (arg[1]), (arg[2])])
 t = str(type(arg))
 s = str(dict1)
 return dict1[Atom(b'prompt')]

def testarg2(arg):
 return arg[Atom(b'format')]

def testarg3(arg):
 t = str(type(arg))
 s = str(arg)
 return [t, s]
  
set_message_handler(handle_message)
