---
title: User Guide
weight: 3
bookFlatSection: true
description: Build a web server with a firewall, a static site, and HTTPS, and learn winch on the way.
---

# User Guide

This guide builds one project: a web server with a firewall, a static
site, and HTTPS. Each page adds one part of the server and the part of
winch that it needs.

1. [Start a project](start/): the project file, and a first command on
   the server.
2. [A web server](web-server/): steps, the plan, and apply.
3. [Environments](environments/): inventories for production and
   staging, variables, and templates.
4. [Groups and pipelines](groups-and-pipelines/): servers with
   different roles.
5. [Recipes](recipes/): the steps, templates, and handlers of one
   service in one place.
6. [HTTPS](https/): a certificate from Let's Encrypt.

You need winch on your machine. The [Quick Start](../) shows how to
install it. You also need a server with Debian 13, Ubuntu 24.04, or
Ubuntu 26.04 that you can log in to with SSH, as root or as a user
with passwordless `sudo`. Later pages add two more servers. Small
virtual machines are enough. The HTTPS page needs a domain name that
points to the web server.

The [Reference](../reference/) has the details of every command, file,
and module.
