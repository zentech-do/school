
aws ecr create-repository \
--repository-name 21522490-final \
--region us-east-1

aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin 605134471711.dkr.ecr.us-east-1.amazonaws.com

docker tag placeholder-app 605134471711.dkr.ecr.us-east-1.amazonaws.com/21522490-final:latest

docker push 605134471711.dkr.ecr.us-east-1.amazonaws.com/21522490-final:latest