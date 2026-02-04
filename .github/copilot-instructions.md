# Copilot Instructions - Ansible Network

## Project Overview
This is a **multi-host Ansible configuration** managing a home lab and VPS infrastructure with:
- **~50 Docker services** (arr suite, monitoring, networking, media)
- **Multiple host groups** organized by workload (watching, pirate/torrents, docker-cluster, stats)
- **Shared infrastructure** with common patterns but role-specific overrides

## Architecture

### Directory Structure
- **`roles/`** - All Ansible roles; subdirectories group related services:
  - `arr/` - Media stack (deluge, radarr, sonarr, prowlarr, jackett, etc.)
  - `docker-*` - Individual service roles (traefik, pihole, vaultwarden, etc.)
  - `basic-server/`, `docker-common/`, `setup/` - Infrastructure setup roles
- **`hosts/production.yml`** - Host inventory with groups (watching, pirate, docker-cluster, minecraft, stats)
- **`group_vars/all/main.yml`** - Global defaults
- **`vars/main.yml`** - Central shared variables (storage paths, docker logging, DNS)
- **`vars/main.vault.yml`** - Encrypted secrets (passwords, VPN keys, API tokens)
- **Playbooks** (`.yml` at root) - Define which roles apply to which hosts

### Key Pattern: Role Structure
Each role follows this standard layout:
```
role-name/
├── defaults/main.yml       # Variables with low precedence (role-specific)
├── tasks/main.yml          # Primary tasks; may include other .yml files
├── handlers/main.yml       # Service restarts, container reloads
├── vars/main.yml           # Higher precedence than defaults
├── templates/              # Jinja2 templates (configs, dockerfiles)
├── files/                  # Static files
└── README.md              # Role documentation
```

## Critical Patterns

### Variable Override Hierarchy
1. **Vault variables** (`vars/main.vault.yml`, `host_vars/*/main.vault.yml`) - passwords, keys
2. **Global variables** (`vars/main.yml`) - shared storage paths, docker settings
3. **Group variables** (`group_vars/*/main.yml`) - per-group overrides
4. **Role variables** (`roles/*/defaults/main.yml`) - role-specific defaults
5. **Inline playbook vars** - lowest priority

**Key shared variables** (from `vars/main.yml`):
- `docker_data_dir: /docker/containers` - Storage base path
- `docker_log_driver: json-file` - All containers use this
- `docker_restart_condition: on-failure` - Default restart policy
- `dns_servers: ['10.1.1.1', '10.1.1.6']` - Internal DNS
- `vault_*` - Encrypted variables from vault (passwords, API keys, VPN config)

### Docker Service Pattern
Most roles deploy containers via `community.docker.docker_container`:
- Use variables from `defaults/main.yml` for sizing, versions, ports
- Reference vault variables for secrets: `"{{ vault_service_key }}"`
- Apply tags matching role name: `tags: [service-name, category]`
- Network mode varies:
  - **Gluetun as VPN gateway**: `network_mode: "container:gluetun"` (arr services)
  - **Traefik routing**: explicit network with traefik labels
  - **Internal DNS**: uses `dns_servers` variable
- Always include: `container_default_behavior: no_defaults`, `recreate: yes`, `pull: true`

**Example** (from docker-deluge):
```yaml
- name: Create and Update Deluge Container
  community.docker.docker_container:
    name: deluge
    image: "lscr.io/linuxserver/deluge:{{ deluge_version }}"
    env:
      PGID: "1000"
      PUID: "1000"
      TZ: "America/Chicago"
    volumes:
      - "/docker/containers/deluge/config:/config"
      - arr-downloads:/downloads
    network_mode: "container:gluetun"  # Route via VPN
    tags: [deluge, arr]
```

### Arr Stack Design
Services in `roles/arr/` form a media automation pipeline:
- **Gluetun** - VPN gateway (all arr services tunnel through it)
- **Deluge** - Torrent client (publishes to prowlarr)
- **Prowlarr** - Index aggregator (feeds radarr/sonarr)
- **Radarr/Sonarr** - Movie/TV downloaders (use deluge + prowlarr)
- All configured with private network + vault credentials

### Deployment Workflow
**Commands** (via `justfile`):
```bash
just install_roles                        # Install external galaxy roles
just update                               # Deploy home_lab.yml to production
just deploy tag:service-name              # Deploy single service by tag
just deploy_vps_all                       # Deploy all VPS playbooks
```

**Execution** (note: runs in distrobox):
```bash
distrobox-enter -H ansible -- ansible-playbook home_lab.yml -i hosts/production.yml
```

**Important**: Playbooks reference vault file path: `vault_password_file = ${HOME}/bin/ansiblePass.sh` (in `ansible.cfg`)

## Common Tasks

### Adding a New Docker Service Role
1. Copy existing role structure (e.g., `roles/docker-audiobookshelf/`)
2. Update `defaults/main.yml` with service-specific variables
3. Create `tasks/main.yml` using `community.docker.docker_container` pattern
4. Add volume mounts to `/docker/containers/{{ service }}/` directory
5. Use tags: `[service-name, category]` (e.g., `[pihole, monitoring]`)
6. Add to appropriate host group in playbook file (e.g., `home_lab.yml`)

### Adding Vault Secrets
Secrets stored in `vars/main.vault.yml` (encrypted):
- Reference as `{{ vault_variable_name }}`
- Use descriptive names: `vault_deluge_api_key`, `vault_gluetun_private_key`
- Decrypt with `ansiblePass.sh` script

### Handling Multiple Hosts
- Modify `hosts/production.yml` to add host group or new host
- Create `host_vars/hostname/main.yml` for host-specific overrides
- Use `group_vars/groupname/main.yml` for group defaults

## Conventions

- **Tag naming**: Match role/service name exactly (e.g., role `docker-pihole` uses `tags: [pihole]`)
- **Variable naming**:
  - Global/shared: lowercase with underscores (`docker_data_dir`, `dns_servers`)
  - Vault secrets: `vault_` prefix (`vault_deluge_api_key`)
  - Role-specific defaults: use role name prefix (`deluge_version`, `pihole_dns_records`)
- **Commented ports**: Many roles have commented `published_ports` and `exposed_ports` (only expose via Traefik for security)
- **File paths**: All container paths use `{{ docker_data_dir }}/{{ service }}/config`
- **User/Group IDs**: Most containers use `PGID: 1000, PUID: 1000`

## Integration Points

- **Traefik** (`roles/docker-traefik/`) - Reverse proxy; services expose via labels, not direct ports
- **Gluetun** - VPN gateway for arr services; other services on main network
- **piHole** - DNS resolver (`dns_servers` points to it)
- **External collections**:
  - `community.general` - `docker_container`, `docker_network`, `docker_volume` modules
  - `community.general` - Additional Docker utilities
  - `geerlingguy.docker` - Docker installation (role)

## Debugging

- **Check role syntax**: `ansible-playbook --syntax-check home_lab.yml`
- **Dry run**: Add `--check` flag to see what would change
- **Verbose output**: `--vvv` flag shows variable values and task execution
- **Single host**: `-l hostname` limits playbook to one host
- **Single tag**: `--tags service-name` deploys only that service
