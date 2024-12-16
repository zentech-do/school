#!/bin/bash


# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)
stack_name="${ProjectName}"


# -------------------------------- Delete K8s Resources -----------------------------------------


kubectl delete namespace todo-namespace


# -------------------------------- Delete Stack -----------------------------------------


# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name $stack_name
exit_status=$?

# Optionally wait for the stack deletion to complete
aws cloudformation wait stack-delete-complete --stack-name $stack_name
exit_status=$?

echo "--------------------------------------------------"
if [ $exit_status -eq 0 ]; then
    echo "Stack $stack_name deleted successfully."
else
    echo "Error: Stack $stack_name deletion did not complete successfully."
fi
echo "--------------------------------------------------"

