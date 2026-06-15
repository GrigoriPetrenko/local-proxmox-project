# Proxmox LXC Lab

A small collection of scripts to create, destroy and deploy a simple LXC-based lab on a Proxmox host.

What this project already does
- Creates three LXC containers (Jenkins, Web, Proxy) from a template and assigns static IPs.
- Configures Jenkins container with Docker, builds a Jenkins image from the provided Dockerfile, and runs Jenkins using CASC (jenkins-casc.yaml).
- Installs Nginx on the Web container and places an index.html there.
- Installs Nginx on the Proxy container and configures it to forward / to the Web container and /jenkins/ to the Jenkins container.

Included scripts
- tmp_var.sh: example variables used by the scripts (HOST, TEMPLATE, CT IDs, IPs, hostnames, gateway).
- variables.sh: empty template to fill with your values.
- create-lxc.sh: creates and starts the three LXC containers using pct.
- destroy-lxc.sh: stops and destroys containers by hostname.
- deploy-app.sh: uploads jenkins-casc.yaml and Dockerfile to the Proxmox host, pushes them into the Jenkins LXC, installs Docker, builds and runs Jenkins, and configures web/proxy.
- run-all.sh: convenience script that runs destroy -> create -> deploy in sequence.

Prerequisites
- A Proxmox VE host accessible via SSH and pct available (the scripts SSH into the host as the user in HOST variable).
- The TEMPLATE variable should point to a valid LXC template on the Proxmox host.
- Place a Dockerfile and jenkins-casc.yaml at the repo root before running deploy-app.sh.

Configuration
1. Copy tmp_var.sh to variables.sh and edit variables.sh to match your environment (HOST, TEMPLATE, CT IDs, IPs, hostnames, GATEWAY).
2. Ensure SSH access to the PROXMOX host (HOST should be like root@proxmox-ip).

Basic usage
- Edit variables.sh with your values.
- ./create-lxc.sh           # create containers
- ./deploy-app.sh           # deploy Jenkins, web and proxy
- ./destroy-lxc.sh jenkins1 web1 proxy   # remove containers by hostname
- ./run-all.sh              # sequence: destroy, create, deploy

Notes
- The scripts assume Debian-based templates and use apt inside containers.
- Review tmp_var.sh to see example values and adjust as needed.
- The project is a work-in-progress; use on a test environment first.
