---
title: Environments
weight: 3
description: Add a staging server with its own inventory, and test changes there before production.
---

# Environments

In this page, you add a staging server, so you can test each change
before it reaches production.

## Inventories

Each environment gets an inventory: a file in `inventories/` that
lists its servers. Move your server into
`inventories/production.yaml`:

```yaml
hosts:
  web1.example.com:
    user: admin
    vars:
      domain: example.com
```

Add the staging server to `inventories/staging.yaml`:

```yaml
hosts:
  staging1.example.com:
    user: admin
    vars:
      domain: staging.example.com
```

`vars` sets values for a server. Here each server gets the domain of
its site.

## Use the domain

Remove `hosts` from `winch.yaml`, and use the domain in the home page:

```yaml
name: example

steps:
  - name: Install nginx and nftables
    pkg:
      name: [nginx, nftables]

  - name: Allow SSH and HTTP; drop the rest
    firewall:
      allow:
        - tcp: [22, 80]

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

`!tpl` marks the content as a template. winch fills in the values of
each server: `{{ .vars.domain }}` becomes the domain of the server.

To check the project for mistakes, run `winch validate`. It connects
to no server. With a typo in the template, you see:

```sh
winch validate
```

```error
winch.yaml:16:16: vars.domian has no value: set it in the inventory, or give it a default; did you mean "domain"?
```

## Plan each environment

With two inventories, tell winch which one to use. Without
`--inventory`, the plan stops:

```sh
winch plan
```

```error
no inventory: use --inventory, or set inventory in winch.yaml
```

Plan production:

```sh
winch plan --inventory production
```

```output
1 host: 0 to change, 1 unchanged, 0 unknown
plan 7dfc50712543ed4a
```

The template gives the same page as before, so production has nothing
to change. Plan staging:

```sh
winch plan --inventory staging
```

```output
staging1.example.com
  example
    + Install nginx and nftables: pkg nginx, nftables
        refresh the package index
        install nginx, nftables
        other packages: known after the refresh
    + Allow SSH and HTTP; drop the rest: firewall
        add tcp 22, 80
        create directory /etc/winch (owner root, group root, mode 0755)
        create file /etc/winch/firewall.nft (owner root, group root, mode 0644)
        create file /etc/systemd/system/winch-firewall.service (owner root, group root, mode 0644)
        create directory /etc/systemd/system/nftables.service.d (owner root, group root, mode 0755)
        create file /etc/systemd/system/nftables.service.d/winch.conf (owner root, group root, mode 0644)
        daemon-reload
        enable winch-firewall.service
        load the rules
    + Write the home page: file /var/www/html/index.html
        create directory /var/www (owner root, group root, mode 0755)
        create directory /var/www/html (owner root, group root, mode 0755)
        owner root, group root, mode 0644
        @@ -0,0 +1,3 @@
        +<!doctype html>
        +<title>staging.example.com</title>
        +<p>Welcome to staging.example.com.</p>
    ~ Run nginx: service nginx
        nginx.service does not exist yet
        enable
        start

1 host: 1 to change, 0 unchanged, 0 unknown
plan 434b04645afcdfde
```

The staging server gets all the steps, with its own domain. Apply
them:

```sh
winch apply --inventory staging
```

Check the page on the staging server:

```sh
winch exec staging1.example.com --inventory staging -- curl -s http://localhost/
```

```output
staging1.example.com
  <!doctype html>
  <title>staging.example.com</title>
  <p>Welcome to staging.example.com.</p>
```

Next: [Groups and pipelines](../groups-and-pipelines/).
