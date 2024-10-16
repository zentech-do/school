#!/bin/bash

if [[ -f outputs.json && -s outputs.json ]]; then
    # Extract the bucket name from outputs.json using jq
    stack_name=$(jq -r '.[] | select(.OutputKey == "StackName") | .OutputValue' outputs.json)
    bucket_name=$(jq -r '.[] | select(.OutputKey == "BucketName") | .OutputValue' outputs.json)

    # Check if stack_name and bucket_name are not null or empty
    if [[ -z "$stack_name" && -z "$bucket_name" ]]; then
        echo "Error: StackName and BucketName is null or empty."
        exit 1
    fi

else
    echo "Error: outputs.json is missing or empty."
    exit 1
fi


# -------------------------------- Delete S3 Bucket -----------------------------------------


# Empty the S3 bucket before deleting it
aws s3 rm s3://"$bucket_name" --recursive

# Delete the S3 bucket
aws s3api delete-bucket --bucket "$bucket_name"
exit_status=$?


echo "--------------------------------------------------"
if [ $exit_status -eq 0 ]; then
    echo "Bucket $bucket_name deleted successfully."
else
    echo "Error: Bucket $bucket_name deletion did not complete successfully."
fi
echo "--------------------------------------------------"


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


