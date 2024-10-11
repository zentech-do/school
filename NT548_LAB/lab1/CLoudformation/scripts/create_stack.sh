#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

if [ -n "$1" ]; then
    bucket_name=$1
else
    # If no argument is passed, prompt the user for the bucket name
    read -p "Enter the name of the S3 bucket you want to create: " bucket_name
fi

if [ -n "$2" ]; then
    stack_name=$2
else
    # If no argument is passed, prompt the user for the bucket name
    read -p "Enter the name of the stack you want to create: " stack_name
fi

echo "BucketName: $bucket_name" > outputs.txt

# Create S3 bucket
./scripts/create_s3.sh $bucket_name

# Upload the YAML files to the newly created bucket
aws s3 cp module/vpc.yaml s3://"$bucket_name"/vpc.yaml
aws s3 cp module/route_table.yaml s3://"$bucket_name"/route_table.yaml
aws s3 cp module/nat_gateway.yaml s3://"$bucket_name"/nat_gateway.yaml
aws s3 cp module/sg.yaml s3://"$bucket_name"/sg.yaml
aws s3 cp module/ec2.yaml s3://"$bucket_name"/ec2.yaml

# Notify that the files were uploaded successfully
echo "Files uploaded successfully to 's3://$bucket_name/'."


echo "StackName: $stack_name" >> outputs.txt

# Create the CloudFormation stack
aws cloudformation create-stack \
  --stack-name $stack_name \
  --template-body file://module/parent_stack.yaml \
  --parameters ParameterKey=BucketName,ParameterValue="$bucket_name"

# Wait until the stack creation is complete (optional but recommended for robustness)
aws cloudformation wait stack-create-complete --stack-name $stack_name

# Output the StackName
echo "Stack '$stack_name' created successfully."
