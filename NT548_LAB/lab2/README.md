- **Change directory:**
  ```
  cd NT548_LAB/lab2/CLoudformation
  ```
- **Create CodePipeline-stack, run the command:**

  ```
  ./scripts/create_stack.sh
  ```

  - Set parameters in `env.json`
    - Create Connectionn to GitHub Repo in AWS CodePipeline settings -> Set `ConnectionArn`
    - Clone ạnd Push source code into GitHub Repo -> Set `RepositoryId`
    - Set IAM Roles for AWS CodePipeline, AWS CodeBuild (build stage) and AWS CloudFormation (deploy stage)

- **Delete CodePipeline-stack (Not Deploy Stack), run the command:**
  ```
  ./scripts/delete_stack.sh
  ```
