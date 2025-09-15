[private]
default:
    just --list

update:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml

update_all:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml

update_homepage:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml --tags homepage

update_torrents:
    distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml --tags torrents

update_rk1:
    distrobox-enter -H ansible -- ansible-playbook rk1.yml -i hosts/rk1.yml --tags homepage