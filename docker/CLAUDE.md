# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform-based Docker infrastructure management project for a home lab environment. It uses Terraform to declaratively manage Docker containers, networks, and related resources with a focus on automation, security, and modularity.

## Architecture

### Core Components
- **OpenTofu Infrastructure**: Uses OpenTofu's `for_each` provider feature for dynamic multi-host Docker management
- **Custom Docker Service Module**: Reusable `docker_svc` module (`modules/docker_svc/`) for standardized container deployment
- **Traefik Reverse Proxy**: Primary routing and load balancing solution with SSL/TLS support
- **Multi-Host Docker**: Dynamic Docker provider configuration using OpenTofu's `for_each` feature
- **Secrets Management**: Integrated with Bitwarden for secure credential handling

### Key Files
- `hosts.tf`: **Central configuration file** - Define all Docker hosts, networks, secrets, and containers here
- `main.tf`: Dynamic resource generation based on host configurations
- `providers.tf`: Dynamic Docker provider configuration using OpenTofu's `for_each` feature
- `config_traefik.tf`: Traefik-specific configuration including routing rules, SSL certificates, and middleware
- `env.tf`: Shared environment variable templates
- `modules/docker_svc/main.tf`: Reusable module handling container lifecycle, networking, DNS, and optional Tailscale integration

## Common Development Commands

```bash
# Initialize Terraform (run first or after adding new providers)
terraform init

# Preview infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy infrastructure (use with caution)
terraform destroy

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate
```

## Development Workflow

### Adding New Docker Hosts
1. **Add host configuration** in `hosts.tf` under `local.docker_hosts`
2. **Define networks, secrets, and containers** for the new host
3. **Run `tofu plan`** to preview the new infrastructure
4. **Apply changes** with `tofu apply`

### Adding New Services to Existing Hosts
1. **Add container configuration** in `hosts.tf` under the appropriate host's `containers` section
2. **Add required networks** if new networks are needed
3. **Add secrets** if the service requires credentials
4. **Update routing** in `config_traefik.tf` if web access is needed

### Configuration Pattern
```hcl
# In hosts.tf
local.docker_hosts = {
  host-name = {
    host     = "ssh://user@hostname:22"
    ssh_opts = [...]

    networks = {
      network-name = {}
    }

    secrets = {
      secret-name = { length = 32 }
    }

    containers = {
      container-name = {
        image   = "image:tag"
        network = ["network-name"]
        # ... other configuration
      }
    }
  }
}
```

### Testing
- Use `tofu plan` to preview changes before applying
- Use `tofu validate` to check configuration syntax
- Test individual services after deployment

## Security Features

- Random password generation for services
- Bitwarden integration for secrets management
- Basic authentication middleware for admin interfaces
- Optional Tailscale integration for secure networking
- SSL/TLS certificate management through Traefik

## Networking Architecture

- Custom Docker networks defined in `main.tf`
- Dynamic DNS record creation for containers
- Traefik handles HTTP/HTTPS entry points and routing
- Support for multiple Docker hosts and networks

## DRY Architecture Benefits

### OpenTofu `for_each` Providers
- **Dynamic host management**: Add new Docker hosts by simply adding entries to `local.docker_hosts`
- **Automatic provider creation**: Each host gets its own Docker provider instance
- **Resource isolation**: Networks, secrets, and containers are automatically namespaced by host

### Centralized Configuration
- **Single source of truth**: All host configurations in `hosts.tf`
- **Consistent structure**: Standardized pattern for hosts, networks, secrets, and containers
- **Easy scaling**: Add new hosts without modifying multiple files

### Module Usage Pattern
The `docker_svc` module provides standardized container deployment with:
- Automatic image pulling and container creation
- Flexible volume, port, and mount configurations
- DNS record management
- Optional Tailscale and custom file uploads
- Network attachment and host assignment

### Key Advantages
1. **No code duplication**: Host-specific configurations are data-driven
2. **Easy maintenance**: Changes to the pattern affect all hosts
3. **Consistent deployment**: Same module and patterns across all hosts
4. **Simple scaling**: Add hosts and services without touching core logic