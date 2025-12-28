[private]
default:
    just --list

install_roles:
    ansible-galaxy install -r roles/requirements.yml -p roles/

update:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml

update_all:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml

deploy tag:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml --tags {{tag}}

deploy_vps_all:
    distrobox-enter -H ansible -- ansible-playbook vps.yml -i hosts/vps.yml

deploy_vps tag:
    distrobox-enter -H ansible -- ansible-playbook vps.yml -i hosts/vps.yml --tags {{tag}}