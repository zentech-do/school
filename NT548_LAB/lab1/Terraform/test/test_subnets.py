import boto3
import pytest
import subprocess

# Lấy VPC ID từ Terraform output
def get_vpc_id():
    output = subprocess.check_output(["terraform", "output", "vpc_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

PUBLIC_SUBNET_CIDR = "10.0.3.0/24"
PRIVATE_SUBNET_CIDR = "10.0.1.0/24"
REGION = "us-west-2"
OUTPUT_FILE = "output_test.txt"

@pytest.fixture(scope="module")
def ec2_client():
    """Khởi tạo client EC2 cho các test case."""
    return boto3.client("ec2", region_name=REGION)

@pytest.fixture(scope="module")
def vpc_id():
    """Lấy VPC ID từ Terraform output."""
    return get_vpc_id()

def log_output(message):
    """Ghi thông điệp vào file output_test.txt."""
    with open(OUTPUT_FILE, 'a') as f:  # Mở file ở chế độ append
        f.write(message + "\n")

def test_public_subnet_created(ec2_client, vpc_id):
    """Kiểm tra xem public subnet có được tạo thành công không."""
    response = ec2_client.describe_subnets(
        Filters=[
            {
                'Name': 'cidrBlock',
                'Values': [PUBLIC_SUBNET_CIDR]
            },
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            }
        ]
    )
    
    assert len(response['Subnets']) == 1, "Không tìm thấy public subnet"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    subnet_info = response['Subnets'][0]
    message = f"Đã tạo thành công Public Subnet: ID = {subnet_info['SubnetId']}, CIDR Block = {subnet_info['CidrBlock']}, VPC ID = {subnet_info['VpcId']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_private_subnet_created(ec2_client, vpc_id):
    """Kiểm tra xem private subnet có được tạo thành công không."""
    response = ec2_client.describe_subnets(
        Filters=[
            {
                'Name': 'cidrBlock',
                'Values': [PRIVATE_SUBNET_CIDR]
            },
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            }
        ]
    )
    
    assert len(response['Subnets']) == 1, "Không tìm thấy private subnet"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    subnet_info = response['Subnets'][0]
    message = f"Đã tạo thành công Private Subnet: ID = {subnet_info['SubnetId']}, CIDR Block = {subnet_info['CidrBlock']}, VPC ID = {subnet_info['VpcId']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file
