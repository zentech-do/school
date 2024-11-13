#!/bin/bash

cd NT548_LAB/lab2/CLoudformation

# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' CI-CD/env.json)

# Use envsubst to replace the variables in .taskcat.template.yml
export ProjectName

envsubst < .taskcat.template.yml > .taskcat.yml

# # Run taskcat
# taskcat test run
