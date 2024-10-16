- **Change directory:**
  ```
  cd NT548_LAB/lab1/CLoudformation
  ```
- **Create stack, run the command:**

  ```
  ./scripts/create_stack.sh lab1-21522490-bucket lab1-21522490-stack
  ```

  - `lab1-21522490-bucket` is the name of S3 bucket \
    `lab1-21522490-stack` is the name of stack in Cloud formation \
    These names can be replaced with other names

  - `output.json` is a file storing these names and Components IDs

- **Run test cases, run the command:**

  ```
  ./scripts/run_test_cases.sh
  ```

  - Place `.env` file in the `test_cases` subfolder. \
    In this file, declare `KEY_FILE_PATH = "path/to/your/key.pem"`

  - Results from test cases is outputted into a `testcase_outputs.json`

- **Delete stack, run the command:**
  ```
  ./scripts/delete_stack.sh
  ```
