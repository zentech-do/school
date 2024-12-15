#!/bin/bash

aws cloudformation deploy \
--stack-name final-21522490 \
--template-file modules/parent_stack.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides file://env.json

