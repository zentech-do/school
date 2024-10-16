import boto3
import pytest
import subprocess

# Lấy Internet Gateway ID từ Terraform output
def get_internet_gateway_id():
    output = subprocess.check_output(["terraform", "output", "ig_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

# Lấy NAT Gateway ID từ Terraform output
def get_nat_gateway_id():
    output = subprocess.check_output(["terraform", "output", "nat_gateway_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

# Lấy Route Table ID cho Route Table công khai từ Terraform output
def get_public_route_table_id():
    output = subprocess.check_output(["terraform", "output", "public_route_table_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

# Lấy Route Table ID cho Route Table riêng tư từ Terraform output
def get_private_route_table_id():
    output = subprocess.check_output(["terraform", "output", "private_route_table_id"]).strip().decode('utf-8')
    return output.strip('"')  # Loại bỏ dấu ngoặc kép

REGION = "us-west-2"  # Thay đổi nếu cần
OUTPUT_FILE = "output_test.txt"

@pytest.fixture(scope="module")
def ec2_client():
    """Khởi tạo client EC2 cho các test case."""
    return boto3.client("ec2", region_name=REGION)

@pytest.fixture(scope="module")
def internet_gateway_id():
    """Lấy Internet Gateway ID từ Terraform output."""
    return get_internet_gateway_id()

@pytest.fixture(scope="module")
def nat_gateway_id():
    """Lấy NAT Gateway ID từ Terraform output."""
    return get_nat_gateway_id()

@pytest.fixture(scope="module")
def public_route_table_id():
    """Lấy Route Table ID công khai từ Terraform output."""
    return get_public_route_table_id()

@pytest.fixture(scope="module")
def private_route_table_id():
    """Lấy Route Table ID riêng tư từ Terraform output."""
    return get_private_route_table_id()

def log_output(message):
    """Ghi thông điệp vào file output_test.txt với một dòng kẻ phân biệt."""
    with open(OUTPUT_FILE, 'a') as f:  # Mở file ở chế độ append
        f.write("=" * 50 + "\n")  # Dòng kẻ trước thông điệp
        f.write(message + "\n")  # Thông điệp
        f.write("\n")  # Dòng trắng sau thông điệp

def test_internet_gateway_created(ec2_client, internet_gateway_id):
    """Kiểm tra xem Internet Gateway có được tạo thành công không."""
    response = ec2_client.describe_internet_gateways(
        InternetGatewayIds=[internet_gateway_id]
    )
    
    assert len(response['InternetGateways']) == 1, "Không tìm thấy Internet Gateway"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    ig_info = response['InternetGateways'][0]
    message = f"Đã tạo thành công Internet Gateway: ID = {ig_info['InternetGatewayId']}, Tên = {ig_info['Tags'][0]['Value']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_nat_gateway_created(ec2_client, nat_gateway_id):
    """Kiểm tra xem NAT Gateway có được tạo thành công không."""
    response = ec2_client.describe_nat_gateways(
        NatGatewayIds=[nat_gateway_id]
    )
    
    assert len(response['NatGateways']) == 1, "Không tìm thấy NAT Gateway"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    nat_info = response['NatGateways'][0]
    message = f"Đã tạo thành công NAT Gateway: ID = {nat_info['NatGatewayId']}, Trạng thái = {nat_info['State']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_public_route_table_created(ec2_client, public_route_table_id):
    """Kiểm tra xem Route Table công khai có được tạo thành công không."""
    response = ec2_client.describe_route_tables(
        RouteTableIds=[public_route_table_id]
    )
    
    assert len(response['RouteTables']) == 1, "Không tìm thấy Route Table công khai"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    public_rt_info = response['RouteTables'][0]
    message = f"Đã tạo thành công Route Table công khai: ID = {public_rt_info['RouteTableId']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_private_route_table_created(ec2_client, private_route_table_id):
    """Kiểm tra xem Route Table riêng tư có được tạo thành công không."""
    response = ec2_client.describe_route_tables(
        RouteTableIds=[private_route_table_id]
    )
    
    assert len(response['RouteTables']) == 1, "Không tìm thấy Route Table riêng tư"
    
    # In ra thông tin khi kiểm tra thành công và ghi vào file
    private_rt_info = response['RouteTables'][0]
    message = f"Đã tạo thành công Route Table riêng tư: ID = {private_rt_info['RouteTableId']}"
    print(message)  # In ra màn hình
    log_output(message)  # Ghi vào file

def test_public_route_table_has_route(ec2_client, public_route_table_id, internet_gateway_id):
    """Kiểm tra xem Route Table công khai có chứa quy tắc đến Internet không."""
    response = ec2_client.describe_route_tables(
        RouteTableIds=[public_route_table_id]
    )
    
    public_rt_info = response['RouteTables'][0]
    assert 'Routes' in public_rt_info, "Route Table công khai không có quy tắc"

    # Kiểm tra quy tắc đến Internet
    routes = public_rt_info['Routes']
    assert any(route['DestinationCidrBlock'] == "0.0.0.0/0" and route['GatewayId'] == internet_gateway_id for route in routes), \
        "Route Table công khai không có quy tắc đến Internet"

def test_private_route_table_has_route(ec2_client, private_route_table_id, nat_gateway_id):
    """Kiểm tra xem Route Table riêng tư có chứa quy tắc đến NAT Gateway không."""
    response = ec2_client.describe_route_tables(
        RouteTableIds=[private_route_table_id]
    )
    
    private_rt_info = response['RouteTables'][0]
    assert 'Routes' in private_rt_info, "Route Table riêng tư không có quy tắc"

    # Kiểm tra quy tắc đến NAT Gateway
    routes = private_rt_info['Routes']
    assert any(route['DestinationCidrBlock'] == "0.0.0.0/0" and route.get('NatGatewayId') == nat_gateway_id for route in routes), \
        "Route Table riêng tư không có quy tắc đến NAT Gateway"