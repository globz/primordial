import os
from PIL import Image
from pathlib import Path
from erlport.erlterms import Atom
from erlport.erlang import set_message_handler, cast

def cast_message(pid, result):
 cast(pid, (Atom(b'python'), result))
 
def register_handler(pid):
 global message_handler
 message_handler = pid
 
def handle_message(message):
 if message_handler:
  result = main()
  cast_message(message_handler, result)

def convert_to_webp(source):
    """Convert image to webp.

    Args:
        source (pathlib.Path): Path to source image

    Returns:
        pathlib.Path: path to new image
    """
    destination = source.with_suffix(".webp")

    image = Image.open(source)  # Open image
    image.save(destination, format="webp")  # Convert image to webp
    os.remove(source)
    
    return str(destination)


def main():
    web_paths = []
    dir_path = Path("apps/primordial_web/priv/static/images/simulation")
    # Switch working directory
    if 'simulation' not in os.getcwd():
        os.chdir(dir_path)    
    paths = Path("apps/primordial_web/priv/static/images/simulation").glob("**/*.png")
    for path in paths:
        webp_path = convert_to_webp(path)
        web_paths.append(webp_path)

    return web_paths

set_message_handler(handle_message)
