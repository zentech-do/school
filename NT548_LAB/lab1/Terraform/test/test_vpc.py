import boto3
import pytest
import subprocess

# Lấy VPC ID từ Terraform output
def get_vpc_id():
    output = subprocess.check_output(["terraform", "output", "vpc_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

VPC_CIDR_BLOCK = "10.0.0.0/16"  # CIDR block của VPC cần kiểm tra
REGION = "us-west-2"  # Thay đổi nếu cần
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
    """Ghi thông điệp vào file output_test_vpc.txt với một dòng kẻ phân biệt."""
    with open(OUTPUT_FILE, 'a') as f:  # Mở file ở chế độ append
        f.write("=" * 50 + "\n")  # Dòng kẻ trước thông điệp
        f.write(message + "\n")  # Thông điệp
        f.write("\n")  # Dòng trắng sau thông điệp

def test_vpc_created(ec2_client):
    """Kiểm tra xem VPC có được tạo thành công không."""
    vpc_id = get_vpc_id()  # Lấy VPC ID
    response = ec2_client.describe_vpcs(
        VpcIds=[vpc_id]
    )
    
    assert len(response['Vpcs']) == 1, "Không tìm thấy VPC"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    vpc_info = response['Vpcs'][0]
    message = f"Đã tạo thành công VPC: ID = {vpc_info['VpcId']}, CIDR Block = {vpc_info['CidrBlock']}, Tên = {vpc_info['Tags'][0]['Value']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file
