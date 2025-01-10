for CERT in $(kubectl get csr | grep -i pending | awk '{print $1}'); do
∙ kubectl certificate approve $CERT                   
∙ done