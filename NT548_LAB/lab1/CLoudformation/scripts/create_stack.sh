#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check for bucket name argument or prompt for it
if [ -n "$1" ]; then
    bucket_name=$1
else
    read -p "Enter the name of the S3 bucket you want to create: " bucket_name
fi

# Check for stack name argument or prompt for it
if [ -n "$2" ]; then
    stack_name=$2
else
    read -p "Enter the name of the stack you want to create: " stack_name
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

# -------------------------------- Upload files into S3 bucket -----------------------------------------
# Upload the YAML files to the newly created bucket
aws s3 cp module/vpc.yaml s3://"$bucket_name"/vpc.yaml
aws s3 cp module/route_table.yaml s3://"$bucket_name"/route_table.yaml
aws s3 cp module/nat_gateway.yaml s3://"$bucket_name"/nat_gateway.yaml
aws s3 cp module/sg.yaml s3://"$bucket_name"/sg.yaml
aws s3 cp module/ec2.yaml s3://"$bucket_name"/ec2.yaml

echo "--------------------------------------------------"
if [ $? -eq 0 ]; then
    echo "Files uploaded successfully to 's3://$bucket_name/'."
else    
    echo "Error: Bucket $bucket_name uploading did not complete successfully."
fi
echo "--------------------------------------------------"

# -------------------------------- Create Stack -----------------------------------------
# Create the CloudFormation stack and capture the output
aws cloudformation create-stack \
  --stack-name "$stack_name" \
  --template-body file://module/parent_stack.yaml \
  --parameters ParameterKey=BucketName,ParameterValue="$bucket_name"

# Write the output to outputs.json in the desired format
jq --arg key "StackName" --arg value "$stack_name" \
   '. += [{OutputKey: $key, OutputValue: $value}]' outputs.json > tmp.json && mv tmp.json outputs.json

# Wait until the stack creation is complete (optional but recommended for robustness)
aws cloudformation wait stack-create-complete --stack-name "$stack_name"

echo "--------------------------------------------------"
echo "Stack '$stack_name' created successfully."
echo "Stack Name written to outputs.json: $stack_name"
echo "--------------------------------------------------"

# -------------------------------- Get Components ID  -----------------------------------------
echo "Gathering outputs from nested stacks..."
resources=$(aws cloudformation describe-stack-resources --stack-name "$stack_name" --query 'StackResources[?ResourceType==`AWS::CloudFormation::Stack`].PhysicalResourceId' --output text)

for resource in $resources; do
    echo $resource
    ComponentIDs=$(aws cloudformation describe-stacks --stack-name "$resource" --query "Stacks[0].Outputs" --output json)
    jq --argjson newOutputs "$ComponentIDs" \
        '. += $newOutputs' outputs.json > tmp.json && mv tmp.json outputs.json
done

echo "--------------------------------------------------"
echo "Components ID written to outputs.json"
echo "--------------------------------------------------"
