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
  result = asyncio.run(count(message))
  cast_message(message_handler, result)

def hello(my_string):
  if isinstance(my_string, bytes):
    my_string = my_string.decode("utf-8")
  
  return "Hello world from " + my_string

async def count(count=100):
  #simluate a time consuming python function
  i = 0
  data = []
  while i < count:
    await asyncio.sleep(1)
    data.append(i+1)
    i = i + 1
  return data


def myasync(count=100):
 return asyncio.run(count2(count))
 
def count2(count=100):
  #simluate a time consuming python function
  i = 0
  data = []
  while i < count:
    # await asyncio.sleep(1)
    time.sleep(1) #sleep for 1 sec
    data.append(i+1)
    i = i + 1
  return data 


# if __name__ == '__main__':
#   print(hello("Python"))

set_message_handler(handle_message)
