#!/bin/bash

# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)
bucket_name="${ProjectName}-bucket"

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


