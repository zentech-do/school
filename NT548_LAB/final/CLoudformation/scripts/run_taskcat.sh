#!/bin/bash

# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)

# Use envsubst to replace the variables in .taskcat.template.yml
export ProjectName

# Create taskcat.yaml
envsubst < .taskcat.template.yml > .taskcat.yml

# Run taskcat
taskcat test run
