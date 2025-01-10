[loadbalancer]
${loadbalancer_ip} ansible_user=ubuntu ansible_become=true ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[control_plane]
%{ for ip in control_plane_ips ~}
${ip} ansible_user=ubuntu ansible_become=true ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}

[workers]
%{ for ip in worker_ips ~}
${ip} ansible_user=ubuntu ansible_become=true ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}
