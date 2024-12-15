#!/bin/bash

# cd NT548_LAB/final/CLoudformation

for template in modules/*.yaml; do
    echo "Linting $template...";
    cfn-lint --template $template;
done
