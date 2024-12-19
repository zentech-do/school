docker buildx build --platform linux/amd64 -t auth-service ./app/auth-service

docker buildx build --platform linux/amd64 -t task-service ./app/task-service

docker buildx build --platform linux/amd64 -t profile-service ./app/profile-service

docker buildx build --platform linux/amd64 -t todo-fe ./app/todo-fe
