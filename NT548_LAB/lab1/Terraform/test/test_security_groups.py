import boto3
import pytest
import subprocess

# Lấy Security Group ID từ Terraform output
def get_security_group_id():
    output = subprocess.check_output(["terraform", "output", "public_sg_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

# Lấy Security Group ID cho nhóm riêng tư từ Terraform output
def get_private_security_group_id():
    output = subprocess.check_output(["terraform", "output", "private_sg_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

REGION = "us-west-2"  # Thay đổi nếu cần
OUTPUT_FILE = "output_test.txt"

@pytest.fixture(scope="module")
def ec2_client():
    """Khởi tạo client EC2 cho các test case."""
    return boto3.client("ec2", region_name=REGION)

@pytest.fixture(scope="module")
def security_group_id():
    """Lấy Security Group ID từ Terraform output."""
    return get_security_group_id()

@pytest.fixture(scope="module")
def private_security_group_id():
    """Lấy Security Group ID cho nhóm riêng tư từ Terraform output."""
    return get_private_security_group_id()

def log_output(message):
    """Ghi thông điệp vào file output_test.txt với một dòng kẻ phân biệt."""
    with open(OUTPUT_FILE, 'a') as f:  # Mở file ở chế độ append
        f.write("=" * 50 + "\n")  # Dòng kẻ trước thông điệp
        f.write(message + "\n")  # Thông điệp
        f.write("\n")  # Dòng trắng sau thông điệp

def test_security_group_created(ec2_client, security_group_id):
    """Kiểm tra xem Security Group có được tạo thành công không."""
    response = ec2_client.describe_security_groups(
        GroupIds=[security_group_id]
    )
    
    assert len(response['SecurityGroups']) == 1, "Không tìm thấy Security Group"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    sg_info = response['SecurityGroups'][0]
    message = f"Đã tạo thành công Security Group: ID = {sg_info['GroupId']}, Tên = {sg_info['GroupName']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_security_group_has_rules(ec2_client, security_group_id):
    """Kiểm tra xem Security Group có các quy tắc không."""
    response = ec2_client.describe_security_groups(
        GroupIds=[security_group_id]
    )
    
    sg_info = response['SecurityGroups'][0]
    assert 'IpPermissions' in sg_info, "Security Group không có quy tắc"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    message = f"Security Group {sg_info['GroupId']} có các quy tắc: {sg_info['IpPermissions']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_private_security_group_created(ec2_client, private_security_group_id):
    """Kiểm tra xem Security Group riêng tư có được tạo thành công không."""
    response = ec2_client.describe_security_groups(
        GroupIds=[private_security_group_id]
    )
    
    assert len(response['SecurityGroups']) == 1, "Không tìm thấy Security Group riêng tư"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    sg_info = response['SecurityGroups'][0]
    message = f"Đã tạo thành công Security Group riêng tư: ID = {sg_info['GroupId']}, Tên = {sg_info['GroupName']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_private_security_group_has_rules(ec2_client, private_security_group_id):
    """Kiểm tra xem Security Group riêng tư có các quy tắc không."""
    response = ec2_client.describe_security_groups(
        GroupIds=[private_security_group_id]
    )
    
    sg_info = response['SecurityGroups'][0]
    assert 'IpPermissions' in sg_info, "Security Group riêng tư không có quy tắc"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    message = f"Security Group riêng tư {sg_info['GroupId']} có các quy tắc: {sg_info['IpPermissions']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file
