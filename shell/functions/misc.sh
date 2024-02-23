#!/bin/bash

# Executes a script if it exists and is executable
run_script() {
    local script_path=$1
    if [ -x "$script_path" ]; then
        echo "Running script: $script_path"
        $script_path
    else
        echo "$script_path not found or not executable"
    fi
}
