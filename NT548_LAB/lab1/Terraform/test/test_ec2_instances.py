import boto3
import pytest
import subprocess

# Hàm để lấy ID các instance từ Terraform output
def get_instance_ids(instance_type):
    output = subprocess.check_output(["terraform", "output", f"{instance_type}_instance_ids"]).strip().decode('utf-8')
    # Chuyển đổi thành danh sách ID, loại bỏ các dấu ngoặc kép và ký tự không cần thiết
    return [id.strip().strip('"') for id in output.strip('[]').split(',') if id.strip()]

REGION = "us-west-2"  # Thay đổi nếu cần
OUTPUT_FILE = "output_test.txt"

@pytest.fixture(scope="module")
def ec2_client():
    """Khởi tạo client EC2 cho các test case."""
    return boto3.client("ec2", region_name=REGION)

def log_output(message):
    """Ghi thông điệp vào file output_test.txt với một dòng kẻ phân biệt."""
    with open(OUTPUT_FILE, 'a') as f:  # Mở file ở chế độ append
        f.write("=" * 50 + "\n")  # Dòng kẻ trước thông điệp
        f.write(message + "\n")  # Thông điệp
        f.write("\n")  # Dòng trắng sau thông điệp

def test_public_instances_created(ec2_client):
    """Kiểm tra xem các instance công cộng có được tạo thành công không."""
    instance_ids = get_instance_ids("public")  # Lấy ID của các instance công cộng
    assert len(instance_ids) > 0, "Không tìm thấy instance công cộng."
    
    # Kiểm tra sự tồn tại của từng instance
    response = ec2_client.describe_instances(InstanceIds=instance_ids)
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            assert instance['State']['Name'] == 'running', f"Instance {instance['InstanceId']} không chạy."
    
    # Ghi thông tin vào file
    message = f"Đã tạo thành công các instance công cộng: {', '.join(instance_ids)}"
    print(message)
    log_output(message)

def test_private_instances_created(ec2_client):
    """Kiểm tra xem các instance riêng tư có được tạo thành công không."""
    instance_ids = get_instance_ids("private")  # Lấy ID của các instance riêng tư
    assert len(instance_ids) > 0, "Không tìm thấy instance riêng tư."
    
    # Kiểm tra sự tồn tại của từng instance
    response = ec2_client.describe_instances(InstanceIds=instance_ids)
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            assert instance['State']['Name'] == 'running', f"Instance {instance['InstanceId']} không chạy."
    
    # Ghi thông tin vào file
    message = f"Đã tạo thành công các instance riêng tư: {', '.join(instance_ids)}"
    print(message)
    log_output(message)

if __name__ == "__main__":
    pytest.main()
