# Setup Docker on CentOS 7

This ansible role will setup docker and docker-compose on CentOS 7 along with SNMP and NRPE.

To remove the monitoring from installing just comment out or remove it from site.yml

```yaml
- hosts: all
  remote_user: root
  roles:
  - common
  - monitoring
  - docker
```

## NTP

With out any alteration NTP is installed and configured by default. This is done in the common role. This can also be removed from this by removing the common role.
