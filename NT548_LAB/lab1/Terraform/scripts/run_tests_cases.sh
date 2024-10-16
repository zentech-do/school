#!/bin/bash

echo "----------------------------------- SUBNET Testing -----------------------------------------" > auto upload to output_test.txt
python3 test/test_subnets.py  

echo "----------------------------------- EC2 Instances Testing -----------------------------------------" > auto upload to output_test.txt

python3 test/test_ec2_instances.py 

echo "----------------------------------- ROUTABLES Testing -----------------------------------------" > auto upload to output_test.txt
python3 test/test_routables.py 

echo "----------------------------------- SECURITY GROUP Testing -----------------------------------------" > auto upload to output_test.txt
python3 test/test_security_groups.py

echo "----------------------------------- VPC Testing -----------------------------------------" > auto upload to output_test.txt
python3 test/test_vpc.py 

echo "Testing complete. Check testcase_output.txt for results."