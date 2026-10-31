---
title: Quick Start
bookFlatSection: true
description: Install winch, and write the message of the day on your server.
---

# Quick Start

## Install

{{< install >}}

## Write the project

Create a directory for the project:

```sh
mkdir hello && cd hello
```

Create `winch.yaml` with the name and the login user of your server:

```yaml
name: hello
hosts:
  web1.example.com:
    user: admin
steps:
  - name: Write the message of the day
    file:
      path: /etc/motd
      content: "Hello from winch.\n"
```

The step writes `/etc/motd`, the message that the server shows when
you log in. winch logs in with `ssh` as `user`: root, or a user with
passwordless `sudo`. If `ssh web1.example.com` does not work, add
`address: 203.0.113.10` under the host, with the address of your
server.

## Plan

To see what winch will change, run `winch plan`:

```sh
winch plan
```

```output
web1.example.com
  hello
    ~ Write the message of the day: file /etc/motd
        @@ -1,7 +1,1 @@
        -
        -The programs included with the Debian GNU/Linux system are free software;
        -the exact distribution terms for each program are described in the
        -individual files in /usr/share/doc/*/copyright.
        -
        -Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
        -permitted by applicable law.
        +Hello from winch.

1 host: 1 to change, 0 unchanged, 0 unknown
plan e216a94e90a21227
```

The plan shows the change as a diff. Nothing changes yet.

## Apply

To make the change, run `winch apply`. It shows the same plan and
asks. Type `y`:

```sh
winch apply
```

```output
Apply these changes? [y/N] y
web1.example.com: hello: ~ Write the message of the day: file /etc/motd

1 host: 1 changed, 0 unchanged
```

Log in to the server with `ssh`. It greets you with `Hello from
winch.`

Run `winch plan` again:

```output
1 host: 0 to change, 1 unchanged, 0 unknown
plan a1a1f73eb8f75003
```

The server matches the project, so there is nothing to change.

## Next

The [User Guide](user-guide/) builds a web server with a firewall,
a static site, and HTTPS.
