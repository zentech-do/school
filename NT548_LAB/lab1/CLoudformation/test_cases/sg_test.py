import boto3
import json
import requests
import paramiko
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


def get_output_value(json_data, key):
    for item in json_data:
        if item['OutputKey'] == key:
            return item['OutputValue']
    return None

def get_public_ip(instance_id):
    ec2 = boto3.client('ec2', region_name='us-east-1')  # Adjust the region if necessary
    response = ec2.describe_instances(InstanceIds=[instance_id])
    public_ip = response['Reservations'][0]['Instances'][0].get('PublicIpAddress')
    return public_ip

def get_private_ip(instance_id):
    ec2 = boto3.client('ec2', region_name='us-east-1')  # Adjust the region if necessary
    response = ec2.describe_instances(InstanceIds=[instance_id])
    private_ip = response['Reservations'][0]['Instances'][0].get('PrivateIpAddress')
    return private_ip

def get_security_group(sg_id):
    """Retrieve security group information."""
    response = ec2.describe_security_groups(GroupIds=[sg_id])
    return response['SecurityGroups'][0] if response['SecurityGroups'] else None


# Function to send HTTP GET request to the public EC2 instance
def send_http_request_from_local(public_ip):
    try:
        response = requests.get(f'http://{public_ip}')
        print(f"HTTP GET Response from {public_ip}:")
        
        if response.status_code == 200:
            # print("Request was successful.")
            return response.status_code  # Success
        else:
            # print(f"Request failed with status code: {response.status_code}")
            return response.status_code  # Failure
    except requests.RequestException as e:
        # print(f"Error sending HTTP request: {e}")
        return 1  # Return 1 on request exception

        
# Function to establish SSH connection
def establish_ssh_connection(public_ip):
    try:
        # Get the key file path from environment variables
        key_file = os.getenv('KEY_FILE_PATH')

        # Initialize SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # Load the private key
        key = paramiko.RSAKey.from_private_key_file(key_file)

        # Connect to the EC2 instance
        ssh.connect(public_ip, username='ec2-user', pkey=key)
        
        # Return the ssh client object if connection is successful
        return ssh
    except Exception as e:
        print(f"Error establishing SSH connection: {e}")
        return None  

# Function to send a command over SSH
def execute_ssh_command(ssh, command):
    try:
        # Execute the command
        stdin, stdout, stderr = ssh.exec_command(command)
        
        # Retrieve the command's output and errors
        output = stdout.read().decode()
        error = stderr.read().decode()

        return output, error
        
    except Exception as e:
        print(f"Exception during command execution: {e}")
        return None, None  

# Function to close ssh connect
def close_ssh_connection(ssh):
    ssh.close()

def upload_files_to_instance(ssh, local_file, remote_path='/home/ec2-user/'):
    file_path = os.path.join(remote_path, os.path.basename(local_file))
    # print(file_path)
    
    command = f"""
        if [ -f '{file_path}' ]; then 
            echo 'File exists'; 
        else 
            echo 'File does not exist'; fi
    """
    output, error = execute_ssh_command(ssh,command)
    # print(f"SSH Output: {output}")
    # print(f"SSH Error: {error}")
    
    if "File exists" not in output:
        try:
            # Initialize SFTP session
            sftp = ssh.open_sftp()
            sftp.put(local_file, file_path)
            sftp.close()
            # print("Uploading key file")
            return file_path
        
        except Exception as e:
            # print(f"Error uploading file: {e}")
            return None
    else:
        # print("Key file has already existed")
        return file_path


# Load the JSON data from a file
with open('outputs.json', 'r') as f:  
    data = json.load(f)

# Initialize the AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')  


# Test case 1: Kiểm tra Public EC2 Security Group
public_sg_id = get_output_value(data, 'PublicInstanceSecurityGroupId')
public_sg = get_security_group(public_sg_id)

if public_sg is not None:
    print("Public EC2 Security Group tồn tại")
    
    public_instance_id = get_output_value(data, 'PublicInstanceId')
    public_ip = get_public_ip(public_instance_id)
    
    # test HTTPs 
    status = send_http_request_from_local(public_ip)
    if status != 200:
        print("Public Instance không thể truy cập từ bên ngoài thông qua HTTP")
    else:
        raise AssertionError("Public Instance có thể truy cập từ bên ngoài thông qua HTTP")

    
    # test SSH
    ssh = establish_ssh_connection(public_ip)
    if ssh: 
        print("Public Instance có thể truy cập từ bên ngoài thông qua SSH")

        command = "curl -I http://www.google.com"
        output, error = execute_ssh_command(ssh, command)
        if "200 OK" in output:
            print("Public Instance có thể truy cập ra bên ngoài")
        else:
            raise AssertionError("Public Instance không thể truy cập ra bên ngoài") 
        
        close_ssh_connection(ssh)
            
    else:
        raise AssertionError("Public Instance không thể truy cập từ bên ngoài thông qua SSH")   
    
else:
    raise AssertionError("Public EC2 Security Group không tồn tại")

print("Test 1: Public Security Group OK")


# Test case 2: Kiểm tra Private EC2 Security Group
private_sg_id = get_output_value(data, 'PrivateInstanceSecurityGroupId')
private_sg = get_security_group(private_sg_id)

if private_sg is not None:
    print("Private EC2 Security Group tồn tại")
    
    private_instance_id = get_output_value(data, 'PrivateInstanceId')
    private_ip = get_private_ip(private_instance_id)
    
    public_instance_id = get_output_value(data, 'PublicInstanceId')
    public_ip = get_public_ip(public_instance_id)
    
    ssh = establish_ssh_connection(public_ip)
    if ssh:
        # Send SSH command from Public to Private Instance
        key_file = os.getenv('KEY_FILE_PATH')
        file_path = upload_files_to_instance(ssh, key_file)
        # print(file_path)
        if file_path:
            command = f"chmod 400 {file_path}"
            output, error = execute_ssh_command(ssh, command)
            # print(f"SSH Output: {output}")
            # print(f"SSH Error: {error}")
        
        command = f"ssh -o StrictHostKeyChecking=no -i '{file_path}' ec2-user@{private_ip} 'echo SSH access to private instance is OK'"
        output, error = execute_ssh_command(ssh, command)
        # print(f"SSH Output: {output}")
        # print(f"SSH Error: {error}")
        
        if error:
            raise AssertionError("Private Instance không thể được truy cập từ Public Instance thông qua SSH")
        else:
            print("Private Instance có thể được truy cập từ Public Instance thông qua SSH" )
            
            command = f"ssh -o StrictHostKeyChecking=no -i '{file_path}' ec2-user@{private_ip} 'curl -I http://www.google.com'"
            output, error = execute_ssh_command(ssh, command)
            # print(f"SSH Output: {output}")
            # print(f"SSH Error: {error}")
            if "200 OK" in output:
                print("Private Instance có thể truy cập ra bên ngoài")
            else:
                raise AssertionError("Private Instance không thể truy cập ra bên ngoài") 
    
        close_ssh_connection(ssh)
        
else:
    raise AssertionError("Public EC2 Security Group không tồn tại")

print("Test 2 Private Security Group OK")
