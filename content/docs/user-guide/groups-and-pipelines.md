---
title: Groups and pipelines
weight: 4
description: Add a database server, and run different steps on servers with different roles.
---

# Groups and pipelines

In this page, you add a database server to production. It needs the
firewall, but not nginx. The steps in `winch.yaml` run on every
server, so you split them by role with groups and a pipeline.

## Groups

Put the web servers in a group, and give the group its open ports.
`inventories/production.yaml`:

```yaml
hosts:
  web1.example.com: {}
  db1.example.com: {}

groups:
  all:
    user: admin
    vars:
      domain: example.com
  web:
    hosts: [web1.example.com]
    vars:
      tcp_ports: [22, 80]
```

- `all` holds every server, so its values apply to all of them.
- `web` holds the web servers. They need port 80 open.

Do the same in `inventories/staging.yaml`:

```yaml
hosts:
  staging1.example.com: {}

groups:
  all:
    user: admin
    vars:
      domain: staging.example.com
  web:
    hosts: [staging1.example.com]
    vars:
      tcp_ports: [22, 80]
```

The other servers keep only SSH open. Set this default in
`winch.yaml`:

```yaml
name: example

vars:
  tcp_ports: [22]
```

The value of a group replaces the default.

## A pipeline

Move the steps into a pipeline with two stages,
`pipelines/site.yaml`:

```yaml
stages:
  - name: base
    hosts: all
    steps:
      - name: Install nftables
        pkg:
          name: nftables

      - name: Allow the open ports; drop the rest
        firewall:
          allow:
            - tcp: !expr vars.tcp_ports

  - name: web
    hosts: web
    steps:
      - name: Install nginx
        pkg:
          name: nginx

      - name: Write the home page
        file:
          path: /var/www/html/index.html
          content: !tpl |
            <!doctype html>
            <title>{{ .vars.domain }}</title>
            <p>Welcome to {{ .vars.domain }}.</p>

      - name: Run nginx
        service:
          name: nginx
          running: true
          enabled: true
```

- `base` runs on all servers. It installs nftables and sets the
  firewall.
- `web` runs on the servers in the group `web`. It installs nginx,
  writes the page, and starts nginx.

`!expr vars.tcp_ports` reads the ports of the server as a list.

## Plan and apply

Plan and apply now take the name of the pipeline:

```sh
winch plan site --inventory production
```

```output
db1.example.com: sending the helper (amd64)
db1.example.com
  base
    + Install nftables: pkg nftables
        refresh the package index
        install nftables
        other packages: known after the refresh
    + Allow the open ports; drop the rest: firewall
        add tcp 22
        create directory /etc/winch (owner root, group root, mode 0755)
        create file /etc/winch/firewall.nft (owner root, group root, mode 0644)
        create file /etc/systemd/system/winch-firewall.service (owner root, group root, mode 0644)
        create directory /etc/systemd/system/nftables.service.d (owner root, group root, mode 0755)
        create file /etc/systemd/system/nftables.service.d/winch.conf (owner root, group root, mode 0644)
        daemon-reload
        enable winch-firewall.service
        load the rules

2 hosts: 1 to change, 1 unchanged, 0 unknown
plan e2cd464e300272a7
```

`db1` gets only the stage `base`. `web1` has nothing to change: its
steps moved into the pipeline, but they describe the same server.
Apply it:

```sh
winch apply site --inventory production
```

To see where nginx runs, give `exec` a group name instead of a server:

```sh
winch exec all --inventory production -- systemctl is-active nginx
```

```output
web1.example.com
  active

db1.example.com
  inactive
  exit status 4
```

The database server has no nginx. `exec` takes a pattern of groups and
servers, such as `web`, `all & !web`, or a server name. `--hosts` of
`plan` and `apply` takes the same patterns. See
[inventory](../../reference/project-files/inventory/).

Next: [Recipes](../recipes/).
