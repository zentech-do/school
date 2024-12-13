docker buildx build --platform linux/amd64 -t placeholder-app ./placeholder_app

docker run -p 8000:8000 placeholder-app
