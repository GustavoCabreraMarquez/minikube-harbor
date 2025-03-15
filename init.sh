helm repo add harbor https://helm.goharbor.io
helm install local harbor/harbor --namespace harbor --create-namespace
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
version=$(helm search repo ingress-nginx/ingress-nginx --versions | head -n 2 | tail -n 1 | awk '{print $2}')
echo "using version $version"
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
--namespace nginx \
--create-namespace \
--version=$version
kubectl patch svc ingress-nginx-controller -n nginx -p '{"spec": {"type": "NodePort"}}'
sleep 5
kubectl rollout restart deployment/ingress-nginx-controller -n nginx
port=$(kubectl get svc ingress-nginx-controller -n nginx | awk '{print $5}' | cut -d ':' -f 2 | cut -d '/' -f 1 | tail -n 1)
address=$(minikube ip)
kubectl delete ing local-harbor-ingress -n harbor
sleep 20
kubectl apply -f ingress-harbor.yaml
echo now add '<'"$address" harbor.local'>' to /etc/hosts
echo Harbor deployment avaliable at harbor.local:"$port"  
kubectl get secret -n harbor harbor-core -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" | base64 -d
