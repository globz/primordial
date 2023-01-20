from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom
import time
import sys
import asyncio

message_handler = None

def cast_message(pid, result):
 cast(pid, (Atom(b'python'), result))
 
def register_handler(pid):
 global message_handler
 message_handler = pid
 
def handle_message(message):
 if message_handler:
  result = testarg2(message)
  #result = asyncio.run(count(message))
  #result = hello2(message) #TODO test message with 2 arguments
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

async def count(count=100):
  #simluate a time consuming python function
  i = 0
  data = []
  while i < count:
    await asyncio.sleep(1)
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

def myasync(count=100):
 return asyncio.run(count2(count))
 
def count2(count=100):
  #simluate a time consuming python function
  i = 0
  data = []
  if (count == 2):
   # cast_message(message_handler, 1)
   return Atom(b'failed')
  while i < count:
    # await asyncio.sleep(1)
    time.sleep(1) #sleep for 1 sec
    data.append(i+1)
    i = i + 1
  return data 


# if __name__ == '__main__':
#   print(hello("Python"))

set_message_handler(handle_message)
