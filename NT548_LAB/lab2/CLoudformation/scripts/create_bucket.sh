#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check for bucket name argument or prompt for it
if [ -n "$1" ]; then
    bucket_name=$1
else
    read -p "Enter the name of the S3 bucket you want to create: " bucket_name
fi

# Start with an empty JSON array
jq -n '[]' > outputs.json

# -------------------------------- Create S3 bucket -----------------------------------------
# Create an S3 bucket
aws s3api create-bucket --bucket "$bucket_name"

# Create a JSON object and pretty-print it into an array structure
jq --arg key "BucketName" --arg value "$bucket_name" \
   '. += [{OutputKey: $key, OutputValue: $value}]' outputs.json > tmp.json && mv tmp.json outputs.json

echo "--------------------------------------------------"
if [ $? -eq 0 ]; then
    echo "Bucket '$bucket_name' created successfully."
    echo "Bucket Name written to outputs.json: $bucket_name"
else    
    echo "Error: Bucket $bucket_name creation did not complete successfully."
fi
echo "--------------------------------------------------"

