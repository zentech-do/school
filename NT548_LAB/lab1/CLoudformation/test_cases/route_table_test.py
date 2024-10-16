import boto3
import json

# Function to retrieve the OutputValue for a given OutputKey from the JSON data
def get_output_value(json_data, key):
    for item in json_data:
        if item['OutputKey'] == key:
            return item['OutputValue']
    return None

def get_route_table(route_table_id):
    """Kiểm tra xem Route Table có tồn tại không và trả về thông tin Route Table nếu có."""
    response = ec2.describe_route_tables(RouteTableIds=[route_table_id])
    return response['RouteTables'][0] if response['RouteTables'] else None

def check_route_to_destination(route_table, destination, gateway_id_key, gateway_id_value):
    """Kiểm tra xem Route Table có route tới destination với gateway tương ứng không."""
    return any(route['DestinationCidrBlock'] == destination and route.get(gateway_id_key) == gateway_id_value for route in route_table['Routes'])




# Load the JSON data from a file
with open('outputs.json', 'r') as f:  # Replace 'outputs.json' with your actual file path
    data = json.load(f)

# Initialize the AWS clients
ec2 = boto3.client('ec2', region_name='us-east-1')  

# Test case 1: Kiểm tra Public Route Table
public_route_table_id = get_output_value(data, 'PublicRouteTableId')
public_route_table = get_route_table(public_route_table_id)
if public_route_table is not None:
    print("Public Route Table tồn tại")
    
    # Kiểm tra nếu Public Route Table được gắn với Public Subnet
    public_subnet_id = get_output_value(data, 'PublicSubnetId')
    public_subnet_association = any(association['SubnetId'] == public_subnet_id for association in public_route_table['Associations'])
    if public_subnet_association:
        print("Public Route Table được gắn với Public Subnet")
        
        # Kiểm tra nếu có route tới 0.0.0.0/0 qua Internet Gateway
        igw_id = get_output_value(data, 'InternetGatewayId')
        public_route_exists = check_route_to_destination(public_route_table, '0.0.0.0/0', 'GatewayId', igw_id)
        if public_route_exists:
            print("Public Route Table có route tới 0.0.0.0/0 qua Internet Gateway")
            print("Test case 1: Public Route Table OK")
        else:
            raise AssertionError("Public Route Table không có route tới 0.0.0.0/0 qua Internet Gateway")
    else:
        raise AssertionError("Public Route Table không được gắn với Public Subnet")
else:
    raise AssertionError("Public Route Table không tồn tại")


# Test case 2: Kiểm tra Private Route Table
private_route_table_id = get_output_value(data, 'PrivateRouteTableId')
private_route_table = get_route_table(private_route_table_id)
if private_route_table is not None:
    print("Private Route Table tồn tại")
    
    # Kiểm tra nếu Private Route Table được gắn với Private Subnet
    private_subnet_id = get_output_value(data, 'PrivateSubnetId')
    private_subnet_association = any(association['SubnetId'] == private_subnet_id for association in private_route_table['Associations'])
    if private_subnet_association:
        print("Private Route Table được gắn với Private Subnet")
        
        # Kiểm tra nếu có route tới 0.0.0.0/0 qua NAT Gateway
        nat_gateway_id = get_output_value(data, 'NatGatewayId')
        private_route_exists = check_route_to_destination(private_route_table, '0.0.0.0/0', 'NatGatewayId', nat_gateway_id)
        if private_route_exists:
            print("Private Route Table có route tới 0.0.0.0/0 qua NAT Gateway")
            print("Test case 2: Private Route Table OK")
        else:
            raise AssertionError("Private Route Table không có route tới 0.0.0.0/0 qua NAT Gateway")
    else:
        raise AssertionError("Private Route Table không được gắn với Private Subnet")
else:
    raise AssertionError("Private Route Table không tồn tại")
