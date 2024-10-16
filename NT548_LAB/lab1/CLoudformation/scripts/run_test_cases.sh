#!/bin/bash

echo "-----------------------------------vpc testing-----------------------------------------" > testcase_output.txt
python test_cases/vpc_test.py >> testcase_output.txt
echo "-----------------------------------route_table testing-----------------------------------------" >> testcase_output.txt
python test_cases/route_table_test.py >> testcase_output.txt
echo "-----------------------------------ec2 testing-----------------------------------------" >> testcase_output.txt
python test_cases/ec2_test.py >> testcase_output.txt
echo "-----------------------------------sg testing-----------------------------------------" >> testcase_output.txt
python test_cases/sg_test.py >> testcase_output.txt