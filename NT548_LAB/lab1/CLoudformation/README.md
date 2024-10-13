- **Change directory:**
  ```
  cd NT548_LAB/lab1/CLoudformation
  ```
- **Create stack, run the command:**

  ```
  ./create_stack.sh lab1-21522490-bucket lab1-21522490-stack
  ```

  - `lab1-21522490-bucket` is the name of S3 bucket
  - `lab1-21522490-stack` is the name of stack in Cloud formation
  - These names can be replaced with other names
  - `output.txt` is a file storing these names

- **Delete stack, run the command:**
  ```
  ./scripts/delete_stack.sh
  ```
