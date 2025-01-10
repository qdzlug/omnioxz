kind: Cluster
name: ${cluster_name}
kubernetes:
  version: ${kubernetes_version}
talos:
  version: ${talos_version}
---
kind: ControlPlane
machines:
%{ for uuid in control_plane_uuids ~}
  - ${uuid}
%{ endfor ~}
---
kind: Workers
machines:
%{ for uuid in worker_uuids ~}
  - ${uuid}
%{ endfor ~}
%{ for uuid in all_machine_uuids ~}
---
kind: Machine
name: ${uuid}
install:
  disk: /dev/sda
%{ endfor ~}
