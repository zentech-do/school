#!/bin/bash

./scripts/delete_s3.sh

if [[ -f outputs.txt && -s outputs.txt ]]; then
        # Read the last line from outputs.txt and extract the bucket name
        stack_name=$(grep "StackName" outputs.txt | cut -d ':' -f 2 | xargs)
else
    echo "Error: outputs.txt is missing or empty."
    exit 1
fi

# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name $stack_name

# Optionally wait for the stack deletion to complete
aws cloudformation wait stack-delete-complete --stack-name $stack_name

echo "Stack $stack_name deleted."
