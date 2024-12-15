
# Extract values from env.json
ProjectName=$(jq -r '.[] | select(.ParameterKey == "ProjectName") | .ParameterValue' env.json)

EksClusterName="${ProjectName}-eks-cluster"

aws eks --region us-east-1 update-kubeconfig --name ${EksClusterName}

kubectl apply -f k8s_configure/namespace.yaml
kubectl apply -f k8s_configure/container_deploy.yaml
kubectl apply -f k8s_configure/service.yaml
kubectl apply -f k8s_configure/ingressclass.yaml
kubectl apply -f k8s_configure/ingress.yaml
kubectl apply -f k8s_configure/hpa.yaml
kubectl apply -f k8s_configure/metrics-server
