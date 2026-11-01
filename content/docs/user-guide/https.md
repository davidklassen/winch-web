---
title: HTTPS
weight: 6
description: Get a certificate from Let's Encrypt, and serve the site over HTTPS.
---

# HTTPS

In this page, the web servers get a certificate from Let's Encrypt and
serve the site over HTTPS. Let's Encrypt connects to your domain on
port 80 to check it, so the DNS record of each domain must point to
its web server.

## Open port 443

In both inventories, add port 443 to `tcp_ports` of the group `web`:

```yaml
    vars:
      tcp_ports: [22, 80, 443]
```

## Get the certificate

In `recipes/nginx/recipe.yaml`, install certbot with nginx:

```yaml
  - name: Install nginx and certbot
    pkg:
      name: [nginx, certbot, python3-certbot-nginx]
```

Add a `certbot` step before `Configure the site`:

```yaml
  - name: Get the TLS certificate
    certbot:
      name: !expr vars.domain
      domains: !expr vars.domain
      email: !tpl webmaster@{{ .vars.domain }}
      deploy_hook: systemctl reload nginx
```

The step gets a certificate for the domain. It comes before the site
config, because the config names the certificate files. certbot renews
the certificate on its own, and `deploy_hook` reloads nginx after each
new certificate.

## Serve HTTPS

Change `recipes/nginx/templates/site.tmpl`:

```
server {
	listen 80;
	listen [::]:80;
	server_name {{ .vars.domain }};
	return 301 https://$host$request_uri;
}

server {
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name {{ .vars.domain }};
	root /var/www/{{ .vars.domain }};

	ssl_certificate /etc/letsencrypt/live/{{ .vars.domain }}/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/{{ .vars.domain }}/privkey.pem;
}
```

Port 80 now redirects to HTTPS, and port 443 serves the site.

## Plan and apply

```sh
winch plan site --inventory staging
```

```output
staging1.example.com
  base
    ~ Allow the open ports; drop the rest: firewall
        add tcp 22, 80, 443
        remove tcp 22, 80
        load the rules
  web
    nginx
      + Install nginx and certbot: pkg nginx, certbot, python3-certbot-nginx
          refresh the package index
          install certbot, python3-certbot-nginx
          also install python3-openssl, python3-josepy, python3-pytz, python3-rfc3339, python3-acme, python3-configargparse, python3-parsedatetime, python3-certbot, libicu76, python3-pyparsing, python3-icu
      + Get the TLS certificate: certbot staging.example.com
          domains staging.example.com
          authenticator nginx
          deploy_hook systemctl reload nginx
      ~ Configure the site: file /etc/nginx/sites-enabled/staging.example.com
          @@ -2,5 +2,15 @@
           	listen 80;
           	listen [::]:80;
           	server_name staging.example.com;
          +	return 301 https://$host$request_uri;
          +}
          +
          +server {
          +	listen 443 ssl;
          +	listen [::]:443 ssl;
          +	server_name staging.example.com;
           	root /var/www/staging.example.com;
          +
          +	ssl_certificate /etc/letsencrypt/live/staging.example.com/fullchain.pem;
          +	ssl_certificate_key /etc/letsencrypt/live/staging.example.com/privkey.pem;
           }
          validate: nginx -t
      ! handler nginx.reload

1 host: 1 to change, 0 unchanged, 0 unknown
plan 4b0778e7e01560bc
```

Apply it:

```sh
winch apply site --inventory staging
```

```output
Apply these changes? [y/N] y
staging1.example.com: base: ~ Allow the open ports; drop the rest: firewall
staging1.example.com: nginx: + Install nginx and certbot: pkg nginx, certbot, python3-certbot-nginx
staging1.example.com: nginx: + Get the TLS certificate: certbot staging.example.com
staging1.example.com: nginx: ~ Configure the site: file /etc/nginx/sites-enabled/staging.example.com
staging1.example.com: nginx: ~ handler nginx.reload: Reload nginx: service nginx

1 host: 1 changed, 0 unchanged
```

Open `https://staging.example.com/` in a browser. To check the
redirect from the server:

```sh
winch exec web --inventory staging -- "curl -s -o /dev/null -w '%{http_code} %{redirect_url}\n' http://localhost/"
```

```output
staging1.example.com
  301 https://localhost/
```

When staging works, apply production.

## What you built

```
example/
  winch.yaml
  inventories/
    production.yaml
    staging.yaml
  pipelines/
    site.yaml
  recipes/
    nginx/
      recipe.yaml
      templates/index.html.tmpl
      templates/site.tmpl
```

A web server with a firewall and HTTPS, a database server with a
firewall, and a staging server to test each change first.

The [Reference](../../reference/) has the details of every
[module](../../reference/modules/), and of topics such as
[handlers](../../reference/project-files/handlers/) and
[templates](../../reference/values/templates/).
