---
title: Start a project
weight: 1
description: Make the project file, and run a first command on the server.
---

# Start a project

A winch project is a directory with a `winch.yaml` file. Create the
directory:

```sh
mkdir example && cd example
```

Add your server to `winch.yaml`:

```yaml
name: example

hosts:
  web1.example.com:
    user: admin
```

`name` is the name of the project. `hosts` lists your servers. `user`
is the user that winch logs in as: root, or a user with passwordless
`sudo`.

winch connects with `ssh` and uses your SSH config. If `ssh
web1.example.com` does not work, add the address of the server:

```yaml
hosts:
  web1.example.com:
    address: 203.0.113.10
    user: admin
```

To check that winch can reach the server, run a command on it with
`winch exec`:

```sh
winch exec web1.example.com -- uptime
```

```output
web1.example.com: sending the helper (amd64)
web1.example.com
   11:35:55 up 2 min,  1 user,  load average: 0.00, 0.00, 0.00
```

You see the output of `uptime` from the server.

Next: [A web server](../web-server/).
