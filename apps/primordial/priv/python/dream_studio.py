import os
import io
import time # remove me
from PIL import Image
from pathlib import Path
from stability_sdk import client
from list_type import list_decoder
from erlport.erlterms import Atom
from erlport.erlang import set_message_handler, cast
import stability_sdk.interfaces.gooseai.generation.generation_pb2 as generation

def cast_message(pid, result):
 cast(pid, (Atom(b'python'), result))
 
def register_handler(pid):
 global message_handler
 message_handler = pid
 
def handle_message(message):
 if message_handler:
  # Decode Elixir's list to Python Dict
  message = list_decoder(message) 
  #result = dream_studio_api(message)
  result = test()
  cast_message(message_handler, result)

# Stability Host URL
os.environ['STABILITY_HOST'] = 'grpc.stability.ai:443'

def dream_studio_api(config):

    prompt_content = config[Atom(b'prompt')]
    output_path = config[Atom(b'path')]
    # Default format to .png if no other format was provided
    config.setdefault(Atom(b'format'), ".png")
    output_format = config[Atom(b'format')]
    
    if isinstance(prompt_content, bytes):
     prompt_content = prompt_content.decode("utf-8")

    if isinstance(output_path, bytes):
     output_path = output_path.decode("utf-8")

    if isinstance(output_format, bytes):
     output_format = output_format.decode("utf-8")
    
    # Set up our connection to the API.
    stability_api = client.StabilityInference(
        key=os.environ['STABILITY_KEY'], # API Key reference, source from ~/primordial/.env
        verbose=True, # Print debug messages.
        engine="stable-diffusion-v1-5", # Set the engine to use for generation. 
        # Available engines: stable-diffusion-v1 stable-diffusion-v1-5 stable-diffusion-512-v2-0 stable-diffusion-768-v2-0 
        # stable-diffusion-512-v2-1 stable-diffusion-768-v2-1 stable-inpainting-v1-0 stable-inpainting-512-v2-0
    )

    # Set up our initial generation parameters.
    answers = stability_api.generate(
        prompt=prompt_content,
        seed=0, # If a seed is provided, the resulting generated image will be deterministic.
                        # What this means is that as long as all generation parameters remain the same, you can always recall the same image simply by generating it again.
                        # Note: This isn't quite the case for Clip Guided generations, which we'll tackle in a future example notebook.
        steps=30, # Amount of inference steps performed on image generation. Defaults to 30. 
        cfg_scale=8.0, # Influences how strongly your generation is guided to match your prompt.
                       # Setting this value higher increases the strength in which it tries to match your prompt.
                       # Defaults to 7.0 if not specified.
        width=512, # Generation width, defaults to 512 if not included.
        height=512, # Generation height, defaults to 512 if not included.
        samples=1, # Number of images to generate, defaults to 1 if not included.
        sampler=generation.SAMPLER_K_DPMPP_2M # Choose which sampler we want to denoise our generation with.
                                                     # Defaults to k_dpmpp_2m if not specified. Clip Guidance only supports ancestral samplers.
                                                     # (Available Samplers: ddim, plms, k_euler, k_euler_ancestral, k_heun, k_dpm_2, k_dpm_2_ancestral, k_dpmpp_2s_ancestral, k_lms, k_dpmpp_2m)
    )

    for resp in answers:
        for artifact in resp.artifacts:
            if artifact.finish_reason == generation.FILTER:
             Atom(b'safe_filter')
            if artifact.type == generation.ARTIFACT_IMAGE:
             img = Image.open(io.BytesIO(artifact.binary))
             img_name = str(artifact.seed)+".png"
             dir_path = Path(output_path)

             # Switch working directory
             if 'simulation' not in os.getcwd():
              os.chdir(dir_path)

             # Save our generated images with their seed number as the filename.
             img.save(img_name)

             if output_format != ".png":
              source = Path(img_name)
              convert_destination = source.with_suffix("."+output_format)
              png_image = Image.open(source)
              png_image.save(convert_destination, format=str(output_format))
              img_name = str(artifact.seed)+"."+output_format
              os.remove(source)
              
             return img_name

def test():
 time.sleep(30)
 return "too late"

set_message_handler(handle_message)
