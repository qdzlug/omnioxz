kind: Cluster
name: my-cluster
kubernetes:
  version: v1.27.0
talos:
  version: v1.5.2
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
