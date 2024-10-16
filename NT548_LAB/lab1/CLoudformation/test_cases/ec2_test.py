import boto3
import json

def get_output_value(json_data, key):
    for item in json_data:
        if item['OutputKey'] == key:
            return item['OutputValue']
    return None

def get_instance(instance_id):
    """Retrieve EC2 instance information."""
    response = ec2.describe_instances(InstanceIds=[instance_id])
    return response['Reservations'][0]['Instances'][0] if response['Reservations'] else None

def check_instance_running(instance):
    """Check if the instance is running."""
    return instance['State']['Name'] == 'running'

def check_public_access(instance):
    """Check if the public instance has a public IP."""
    return 'PublicIpAddress' in instance and instance['PublicIpAddress'] is not None



# Load the JSON data from a file
with open('outputs.json', 'r') as f:  
    data = json.load(f)
    
# Initialize the AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')  

# Test case 1: Verify Public EC2 Instance
public_instance_id = get_output_value(data, 'PublicInstanceId')
public_instance = get_instance(public_instance_id)

if public_instance is not None:
    print("Public EC2 Instance tồn tại")
    
    # Check if the instance is running
    if check_instance_running(public_instance):
        print("Public EC2 Instance đang chạy")
        
        # Check if it has a public IP
        if check_public_access(public_instance):
            print("Public EC2 Instance có địa chỉ Public IP")
            print("Test case 1: Public EC2 Instance OK")
        else:
            raise AssertionError("Public EC2 Instance không có địa chỉ Public IP")
    else:
        raise AssertionError("Public EC2 Instance không đang chạy")
else:
    raise AssertionError("Public EC2 Instance không tồn tại")

# Test case 2: Verify Private EC2 Instance
private_instance_id = get_output_value(data, 'PrivateInstanceId')
private_instance = get_instance(private_instance_id)

if private_instance is not None:
    print("Private EC2 Instance tồn tại")
    
    # Check if the instance is running
    if check_instance_running(private_instance):
        print("Private EC2 Instance đang chạy")
        
        if check_public_access(private_instance):
            raise AssertionError("Private EC2 Instance có địa chỉ Public IP")
        else:
            print("Private EC2 Instance không có địa chỉ Public IP")
            print("Test case 2: Private EC2 Instance OK")
            
    else:
        raise AssertionError("Private EC2 Instance không đang chạy")
else:
    raise AssertionError("Private EC2 Instance không tồn tại")
