## Etapes pour déployer l'infrastructure et l'application sur Azure

Dans le dossier terraform:
terraform init
terraform plan -var="student_name=<votre_nom>"
terraform apply -var="student_name=<votre_nom>"


Dans le dossier flask-app:
az acr login --name acrESGI<votre_nom>
docker build -t flask-app .
docker tag flask-app acresgi<votre_nom>.azurecr.io/flask-app
docker push acresgi<votre_nom>.azurecr.io/flask-app

Dans le dossier kubernetes:
az aks get-credentials --overwrite-existing -n aks-<votre_nom> -g rg-ESGI-<votre_nom>
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.loadBalancerIP=<your_public_ip>

Changer le nom de l'image dans le fichier flask-deployment.yaml par le nom de votre registry azure

kubectl apply -f redis-deployment.yaml
kubectl apply -f flask-deployment.yaml  
kubectl apply -f ingress.yaml
kubectl get pods