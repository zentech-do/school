import boto3

# Initialize the AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')  # Chỉnh sửa 'region_name' theo khu vực của bạn

def get_vpc(vpc_id):
    """Kiểm tra xem VPC có tồn tại không và trả về thông tin VPC nếu có."""
    response = ec2.describe_vpcs(VpcIds=[vpc_id])
    return response['Vpcs'][0] if response['Vpcs'] else None

def get_subnet(subnet_id):
    """Kiểm tra xem Subnet có tồn tại không."""
    response = ec2.describe_subnets(SubnetIds=[subnet_id])
    return response['Subnets'][0] if response['Subnets'] else None

def get_internet_gateway(igw_id):
    """Kiểm tra xem Internet Gateway có tồn tại và gắn vào VPC không."""
    response = ec2.debcribe_internet_gateways(InternetGatewayIds=[igw_id])
    return response['InternetGateways'][0] if response['InternetGateways'] else None

def get_security_group(sg_id):
    """Kiểm tra Security Group."""
    response = ec2.describe_security_groups(GroupIds=[sg_id])
    return response['SecurityGroups'][0] if response['SecurityGroups'] else None






# Test case 1: Kiểm tra VPC
vpc_id = "vpc-xxxxxx"  # Thay bằng ID của VPC bạn
vpc = get_vpc(vpc_id)
print("Test case 1: VPC OK")

# Test case 2: Kiểm tra Public Subnet
public_subnet_id = "subnet-xxxxxx"  # Thay bằng ID của Public Subnet
public_subnet = get_subnet(public_subnet_id)
assert public_subnet['CidrBlock'] == '10.0.1.0/24', f"Public Subnet có CIDR block {public_subnet['CidrBlock']}, mong đợi 10.0.1.0/24"
assert public_subnet['MapPublicIpOnLaunch'] is True, "Public Subnet không tự động cấp IP công khai"
print("Test case 2: Public Subnet OK")

# Test case 3: Kiểm tra Private Subnet
private_subnet_id = "subnet-yyyyyy"  # Thay bằng ID của Private Subnet
private_subnet = get_subnet(private_subnet_id)
assert private_subnet['CidrBlock'] == '10.0.2.0/24', f"Private Subnet có CIDR block {private_subnet['CidrBlock']}, mong đợi 10.0.2.0/24"
print("Test case 3: Private Subnet OK")

# Test case 4: Kiểm tra Internet Gateway
igw_id = "igw-xxxxxx"  # Thay bằng ID của Internet Gateway
igw = get_internet_gateway(igw_id)
assert any(attachment['VpcId'] == vpc_id for attachment in igw['Attachments']), "Internet Gateway chưa được gắn vào VPC"
print("Test case 4: Internet Gateway OK")

# Test case 5: Kiểm tra Security Group
sg_id = "sg-xxxxxx"  # Thay bằng ID của Security Group
sg = get_security_group(sg_id)
ingress_rules = sg['IpPermissions']
egress_rules = sg['IpPermissionsEgress']
# Kiểm tra quy tắc ingress cho SSH và HTTP
assert any(rule['FromPort'] == 22 and rule['ToPort'] == 22 for rule in ingress_rules), "Không tìm thấy quy tắc SSH (port 22)"
assert any(rule['FromPort'] == 80 and rule['ToPort'] == 80 for rule in ingress_rules), "Không tìm thấy quy tắc HTTP (port 80)"
# Kiểm tra tất cả outbound được cho phép
assert any(rule['IpProtocol'] == '-1' for rule in egress_rules), "Outbound không được cho phép cho tất cả giao thức"
print("Test case 5: Security Group OK")
