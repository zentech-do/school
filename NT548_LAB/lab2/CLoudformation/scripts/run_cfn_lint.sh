#!/bin/bash

# cd NT548_LAB/lab2/CLoudformation

for template in module/*.yaml; do
    echo "Linting $template...";
    cfn-lint --template $template;
done
