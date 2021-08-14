# [Ansible](https://www.ansible.com/) Workspace
    Automates server management
   
    From creating a server instance to maintaining 
    os, tools, softwares and their versions.

    This project is mainly created to support Ubuntu:20.04. Any other os was NOT tested and
    probably wont work without modifications. 
    

Written by @jayjah(jayjah1) <markuskrebs93@gmail.com>


#### Note:
    add files:
    - id_rsa.pem :: private server ssh key (see ssh paragraph)
    - public_server_key :: public server ssh key (see ssh paragraph)
    - public_user_key :: public user ssh key 
    -> both keys will correspond to the same user defined in vars and root user on remote host
    => see scripts/ for more detailed information

    ssh:
    A private ssh file should be created for the ansible server itself. This ensures a conflict free work when automating server instances. This file should be in a `.pem` format. Respectively a public ssh key corresponding to that private file should exist as well in the root project directory.
    

### Playbooks

- create-server.yml
    Creates a hetzner server instance

- list-server.yml
    List all hetzner server instances from your hetzner account

- ssl-server.yml
    Installs nginx and letsencrypt, configures them as well to support https connections

- update-server.yml
    Makes full update, includes kernel update

- restic-server.yml
    Creates a restic server instance in a docker environment

- restic-client.yml
    Creates and initializes restic client

- server.yml
    Set up server with all needed dependencies, tools, etc.

    ### Roles

    - common (os tools/softwares)

    - firewall (ufw)

    - user

    - ssh

    - dart

    - docker

    - postgres

    - redis


#### Instructions:

- adjust /vars files to your need and rename them. Remove the `_template` suffix
    
- place ssh keys into root directory (private + public keys; read Note(!))
    
- set up an ansible server instance with docker build.



#### Instructions for adding a new backend server:

- add server in vars/create_default.yml
- run `ansible-playbook create-server.yml`
 -> add created server in vars/hosts
- run all needed playbooks



