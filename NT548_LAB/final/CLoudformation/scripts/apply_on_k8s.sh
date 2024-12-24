
# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)
EksClusterName="${ProjectName}-eks-cluster"

aws eks --region us-east-1 update-kubeconfig --name ${EksClusterName}

# Load environment variables from .env file
if [ -f scripts/.image.env ]; then
    export $(cat scripts/.image.env | xargs)
else
    echo ".image.env file not found. Please create one with DOCKER_USERNAME and DOCKER_PASSWORD."
    exit 1
fi


kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL


# kubectl apply -f k8s_configure/namespace.yaml
# kubectl apply -f k8s_configure/container_deploy.yaml
# kubectl apply -f k8s_configure/service.yaml



#Tạo namespace
kubectl apply -f app/k8s/infrastructure/namespace.yaml

#Tạo config map
kubectl create configmap mysql-init --from-file=app/data.sql --namespace=todo-namespace
kubectl create configmap tyk-config --from-file=app/gateway/tyk.standalone.conf -n todo-namespace
kubectl create configmap tyk-apps --from-file=app/gateway/apps -n todo-namespace
kubectl create configmap grafana-config --from-file=app/grafana.ini -n todo-namespace
kubectl create configmap prometheus-config --from-file=app/prometheus.yml -n todo-namespace

#Tạo các infrastructure

kubectl apply -f app/k8s/infrastructure/mysql.yaml
kubectl apply -f app/k8s/infrastructure/redis.yaml
kubectl apply -f app/k8s/infrastructure/gateway.yaml

#Tạo application
kubectl apply -f app/k8s/application/auth-service.yaml
kubectl apply -f app/k8s/application/task-service.yaml
kubectl apply -f app/k8s/application/user-service.yaml
kubectl apply -f app/k8s/application/todo-fe.yaml

#Monitoring
kubectl apply -f app/k8s/infrastructure/grafana-pvc.yaml
kubectl apply -f app/k8s/infrastructure/prometheus-pvc.yaml
kubectl apply -f app/k8s/infrastructure/monitoring.yaml

#Autoscaling
kubectl apply -f app/k8s/infrastructure/hpa.yaml
kubectl apply -f app/k8s/infrastructure/metrics-server

#Ingress
kubectl apply -f app/k8s/infrastructure/ingressclass.yaml
kubectl apply -f app/k8s/infrastructure/ingress.yaml