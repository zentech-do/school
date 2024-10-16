import boto3
import json

# Function to retrieve the OutputValue for a given OutputKey from the JSON data
def get_output_value(json_data, key):
    for item in json_data:
        if item['OutputKey'] == key:
            return item['OutputValue']
    return None

def get_vpc(vpc_id):
    """Kiểm tra xem VPC có tồn tại không và trả về thông tin VPC nếu có."""
    response = ec2.describe_vpcs(VpcIds=[vpc_id])
    return response['Vpcs'][0] if response['Vpcs'] else None

def get_subnet(subnet_id):
    """Kiểm tra xem Subnet có tồn tại không."""
    response = ec2.describe_subnets(SubnetIds=[subnet_id])
    return response['Subnets'][0] if response['Subnets'] else None

def get_nat_gateway(nat_gateway_id):
    """Kiểm tra xem NAT Gateway có tồn tại không và trả về thông tin NAT Gateway nếu có."""
    response = ec2.describe_nat_gateways(NatGatewayIds=[nat_gateway_id])
    return response['NatGateways'][0] if response['NatGateways'] else None

def get_internet_gateway(igw_id):
    """Kiểm tra xem Internet Gateway có tồn tại và gắn vào VPC không."""
    response = ec2.describe_internet_gateways(InternetGatewayIds=[igw_id])
    return response['InternetGateways'][0] if response['InternetGateways'] else None

def get_security_group(sg_id):
    """Kiểm tra Security Group."""
    response = ec2.describe_security_groups(GroupIds=[sg_id])
    return response['SecurityGroups'][0] if response['SecurityGroups'] else None



# Load the JSON data from a file
with open('outputs.json', 'r') as f:  
    data = json.load(f)

# Initialize the AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')  

# Test case 1: Kiểm tra VPC
vpc_id = get_output_value(data, 'VPCId')
vpc = get_vpc(vpc_id)
if vpc is not None:
    print("VPC tồn tại")
    print("Test case 1: VPC OK")
else:
    raise AssertionError("VPC không tồn tại")

# Test case 2: Kiểm tra Subnet
public_subnet_id = get_output_value(data, 'PublicSubnetId')
public_subnet = get_subnet(public_subnet_id)
private_subnet_id = get_output_value(data, 'PrivateSubnetId')
private_subnet = get_subnet(private_subnet_id)
if public_subnet is not None:
    print("Public Subnet tồn tại")
else:
    raise AssertionError("Public Subnet không tồn tại")

if private_subnet is not None:
    print("Private Subnet tồn tại")
else:
    raise AssertionError("Private Subnet không tồn tại")

print("Test case 2: Subnet OK")

# Test case 3: Kiểm tra NAT Gateway
nat_gateway_id = get_output_value(data, 'NatGatewayId')
nat_gateway = get_nat_gateway(nat_gateway_id)
if nat_gateway is not None:
    print("NAT Gateway tồn tại")
    print("Test case 3: NAT Gateway OK")
else:
    raise AssertionError("NAT Gateway không tồn tại")

# Test case 4: Kiểm tra Internet Gateway
igw_id = get_output_value(data, 'InternetGatewayId')
igw = get_internet_gateway(igw_id)
if igw is not None:
    print("Internet Gateway Gateway tồn tại")
    if any(attachment['VpcId'] == vpc_id for attachment in igw['Attachments']):
        print("Internet Gateway đã được gắn vào VPC")
        print("Test case 4: Internet Gateway OK")
    else:
        raise AssertionError("Internet Gateway chưa được gắn vào VPC")
else:
    raise AssertionError("Internet Gateway không tồn tại")

# Test case 5: Kiểm tra Security Group
sg_id = get_output_value(data, 'DefaultSecurityGroupId')
sg = get_security_group(sg_id)

if sg is not None:
    print("Default Security Group tồn tại")
    
    ingress_rules = sg['IpPermissions']
    egress_rules = sg['IpPermissionsEgress']
    
    # Allowed inbound ports: SSH (22) and HTTP (80)
    allowed_ports = [22, 80]
    
    # Kiểm tra quy tắc ingress cho SSH và HTTP
    for rule in ingress_rules:
        from_port = rule.get('FromPort')
        to_port = rule.get('ToPort')
        
        # Disallow port ranges, only specific ports 22 and 80 should be allowed
        if from_port != to_port:
            raise AssertionError(f"SG đang cho phép các port không phải {allowed_ports} hoặc đang sử dụng port range từ {from_port} đến {to_port}")

        # Check if the port is neither 22 nor 80
        if from_port not in allowed_ports:
            raise AssertionError(f"SG đang cho phép port {from_port}, không phải port {allowed_ports}")
        
    print(f"Inbound traffic: Chỉ cho phép port {allowed_ports} OK")
    
    # Kiểm tra tất cả outbound được cho phép
    for rule in egress_rules:
        if rule['IpProtocol'] == '-1':
            print("Outbound traffic: được cho phép cho tất cả giao thức")
        else:
            raise AssertionError("Outbound traffic hiện không được cho phép cho tất cả giao thức")
        
else:
    raise AssertionError("Default Security Group không tồn tại")

print("Test case 5: Security Group OK")