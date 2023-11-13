#!/bin/bash

# Pre-requisite ::
# Navigate to the root of your project folder
# Create project venv
# ( python3 -m venv .venv && source .venv/bin/activate )
# ( Add .venv to .gitignore )

# Install project requirements
# ( pip install -r requirements.txt )

# How to use python-venv.sh ::
# Navigate to your project folder
# Source activate.sh
# ( . python-venv.sh )
# To leave venv type: ( deactivate )

# How to update requirements.txt
# Install new dependencies with pip
# Then update requirements.txt
# (pip freeze > requirements.txt)

# You may also run the interpreter directly within venv
# This is how primordial invokes it via erl_port
# .venv/bin/python3


if [[ "$0" = "$BASH_SOURCE" ]]; then
    echo "Needs to be run using source: . python-venv.sh"
fi

activate () {
    source ".venv/bin/activate"
}

activate
