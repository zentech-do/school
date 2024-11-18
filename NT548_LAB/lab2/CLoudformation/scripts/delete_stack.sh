#!/bin/bash

bucket_name=lab2-21522490-codepipeline-bucket
stack_name=CodePipelineStack



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

