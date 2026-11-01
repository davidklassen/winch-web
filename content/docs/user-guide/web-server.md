---
title: A web server
weight: 2
description: Install nginx behind a firewall, read the plan, and apply it.
---

# A web server

In this page, you install nginx, turn on a firewall, and write a home
page.

Add these steps to `winch.yaml`:

```yaml
name: example

hosts:
  web1.example.com:
    user: admin

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
      content: |
        <!doctype html>
        <title>example.com</title>
        <p>Hello from winch.</p>

  - name: Run nginx
    service:
      name: nginx
      running: true
      enabled: true
```

The steps run in order:

1. `pkg` installs nginx, and nftables for the firewall.
2. `firewall` allows SSH and HTTP, and drops all other incoming
   traffic.
3. `file` writes the home page into the web root of nginx.
4. `service` starts nginx, and starts it again at each boot.

`name` describes the step in the output. The
[modules](../../reference/modules/) reference lists the arguments of
each module.

## Plan

To see what winch will change, run `winch plan`:

```sh
winch plan
```

```output
web1.example.com
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
        +<title>example.com</title>
        +<p>Hello from winch.</p>
    ~ Run nginx: service nginx
        nginx.service does not exist yet
        enable
        start

1 host: 1 to change, 0 unchanged, 0 unknown
plan 16580ad9c636c795
```

The plan lists each step that will change something on the server. `+`
marks something new, and `~` marks a change. Under each step, you see
what exactly will happen. The plan changes nothing on the server.

## Apply

To make the changes, run `winch apply`. It shows the same plan and
asks. Type `y`:

```sh
winch apply
```

```output
Apply these changes? [y/N] y
web1.example.com: example: + Install nginx and nftables: pkg nginx, nftables
web1.example.com: example: + Allow SSH and HTTP; drop the rest: firewall
web1.example.com: example: + Write the home page: file /var/www/html/index.html

1 host: 1 changed, 0 unchanged
```

`Run nginx` has no line: the install of the package already started
nginx.

Check the page from the server:

```sh
winch exec web1.example.com -- curl -s http://localhost/
```

```output
web1.example.com
  <!doctype html>
  <title>example.com</title>
  <p>Hello from winch.</p>
```

Run `winch plan` again:

```output
1 host: 0 to change, 1 unchanged, 0 unknown
plan a45062412bba9ac8
```

The server matches the project, so there is nothing to change.

## Change the page

Change the text of the page in `winch.yaml`:

```yaml
      content: |
        <!doctype html>
        <title>example.com</title>
        <p>Welcome to example.com.</p>
```

`winch plan` shows the change as a diff:

```output
web1.example.com
  example
    ~ Write the home page: file /var/www/html/index.html
        @@ -1,3 +1,3 @@
         <!doctype html>
         <title>example.com</title>
        -<p>Hello from winch.</p>
        +<p>Welcome to example.com.</p>

1 host: 1 to change, 0 unchanged, 0 unknown
plan c0c0648e5fb0e750
```

Apply it with `winch apply`.

Next: [Environments](../environments/).
