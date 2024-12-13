#!/bin/bash

# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)
BucketName="${ProjectName}-bucket"

aws s3api create-bucket --bucket "${BucketName}"