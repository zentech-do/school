#!/bin/bash

# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)
stack_name="${ProjectName}"

aws cloudformation deploy \
--stack-name $stack_name \
--template-file modules/parent_stack.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides file://env.json

