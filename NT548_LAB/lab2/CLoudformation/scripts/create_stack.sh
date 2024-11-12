aws cloudformation deploy \
--stack-name CodePipelineStack \
--template-file CI-CD/pipeline.yml \
--capabilities CAPABILITY_IAM \
--parameter-overrides file://CI-CD/env.json

