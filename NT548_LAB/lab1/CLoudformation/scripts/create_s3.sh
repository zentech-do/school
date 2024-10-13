#!/bin/bash

set -e  # Enable debugging and exit on error

# Check if the first argument is provided (not empty)
if [ -n "$1" ]; then
    bucket_name=$1
else
    # If no argument is passed, prompt the user for the bucket name
    read -p "Enter the name of the S3 bucket you want to create: " bucket_name
fi

# Create an S3 bucket
aws s3api create-bucket --bucket "$bucket_name" 

# Notify that the bucket was created successfully
echo "Bucket '$bucket_name' created successfully."
