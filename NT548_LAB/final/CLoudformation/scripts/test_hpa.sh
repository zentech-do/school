#!/bin/bash

# Variables
NAMESPACE="fastapi-placeholder"     # Set your namespace
SERVICE_NAME="service-fastapi-placeholder" # Update this to match your service name
DEPLOYMENT_NAME="deployment-fastapi-placeholder"  # Update to match your Deployment name
LOAD_GENERATOR_IMAGE="busybox"     # Using BusyBox as the load generator image
LOAD_URL="http://${SERVICE_NAME}"  # Update if your service is exposed via Ingress

echo "Namespace: $NAMESPACE"
echo "Service Name: $SERVICE_NAME"
echo "Deployment Name: $DEPLOYMENT_NAME"
echo "Starting HPA test..."

# 1. Ensure HPA is set up
echo "Checking HPA configuration..."
kubectl get hpa -n $NAMESPACE
if [ $? -ne 0 ]; then
  echo "HPA is not configured for $DEPLOYMENT_NAME. Exiting..."
  exit 1
fi

# 2. Check initial number of pods
INITIAL_PODS=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.status.replicas}')
echo "Initial number of replicas: $INITIAL_PODS"

# 3. Start load generation
echo "Starting load generator..."
kubectl run -i --tty load-generator --rm --image=$LOAD_GENERATOR_IMAGE --restart=Never -n $NAMESPACE \
  -- /bin/sh -c "while sleep 0.01; do wget -q -O- $LOAD_URL; done" &
LOAD_PID=$!

# 4. Monitor pod scaling
echo "Monitoring pod scaling..."
for i in {1..10}; do
  sleep 20  # Wait 20 seconds to allow the HPA to scale pods
  NEW_PODS=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.status.replicas}')
  echo "Current number of replicas: $NEW_PODS"
  
  # Check if scaling happened
  if [ "$NEW_PODS" -gt "$INITIAL_PODS" ]; then
    echo "HPA successfully scaled pods to $NEW_PODS replicas!"
    break
  fi
done

# 5. Stop load generation
echo "Stopping load generator..."
kill $LOAD_PID

# 6. Check if scaling down happens (Optional)
echo "Waiting for pods to scale down..."
sleep 120
FINAL_PODS=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.status.replicas}')
echo "Final number of replicas after scaling down: $FINAL_PODS"

echo "HPA test completed."
