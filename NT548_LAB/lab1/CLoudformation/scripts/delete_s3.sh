#!/bin/bash

set -e

if [[ -f outputs.txt && -s outputs.txt ]]; then
        # Read the last line from outputs.txt and extract the bucket name
        bucket_name=$(grep "BucketName" outputs.txt | cut -d ':' -f 2 | xargs)
        echo "Deleting Bucket Name: $bucket_name"
else
    echo "Error: outputs.txt is missing or empty."
    exit 1
fi

# Empty the S3 bucket before deleting it
aws s3 rm s3://"$bucket_name" --recursive

# Delete the S3 bucket
aws s3api delete-bucket --bucket "$bucket_name"

echo "S3 bucket $bucket_name deleted."