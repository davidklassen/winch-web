---
title: Recipes
weight: 5
description: Move the nginx steps into a recipe, and serve the site from its own config.
---

# Recipes

In this page, you give nginx its own site config. The nginx steps
grow, so you move them into a recipe: a directory with the steps,
templates, and handlers of one service.

## The recipe

Create the recipe `nginx`:

```
recipes/nginx/
  recipe.yaml
  templates/index.html.tmpl
  templates/site.tmpl
```

`templates/index.html.tmpl` is the home page:

```
<!doctype html>
<title>{{ .vars.domain }}</title>
<p>Welcome to {{ .vars.domain }}.</p>
```

`templates/site.tmpl` is the site config of nginx:

```
server {
	listen 80;
	listen [::]:80;
	server_name {{ .vars.domain }};
	root /var/www/{{ .vars.domain }};
}
```

`recipe.yaml` holds the steps:

```yaml
steps:
  - name: Install nginx
    pkg:
      name: nginx

  - name: Write the home page
    file:
      path: !tpl /var/www/{{ .vars.domain }}/index.html
      template: index.html.tmpl

  - name: Configure the site
    file:
      path: !tpl /etc/nginx/sites-enabled/{{ .vars.domain }}
      template: site.tmpl
      validate: nginx -t
    notify: reload

  - name: Remove the other sites
    dir:
      path: /etc/nginx/sites-enabled
      purge: true
    notify: reload

  - name: Run nginx
    service:
      name: nginx
      running: true
      enabled: true

handlers:
  reload:
    - name: Reload nginx
      service:
        name: nginx
        reloaded: true
```

The new steps:

- `Write the home page` fills in `index.html.tmpl` and writes it to the
  directory of the site.
- `Configure the site` fills in `site.tmpl`. `validate: nginx -t`
  checks the config after winch writes it. When the check fails, winch
  puts the old file back, and the step fails.
- `Remove the other sites` removes everything in `sites-enabled` that no
  step writes: here, the default site of Debian.
- `notify: reload` runs the handler `reload` when the step changes
  something. The handler reloads nginx once, after the last step of the
  recipe.

## Use the recipe

In `pipelines/site.yaml`, replace the steps of the stage `web` with the
recipe:

```yaml
  - name: web
    hosts: web
    steps:
      - recipe: nginx
```

## Plan and apply

```sh
winch plan site --inventory staging
```

```output
staging1.example.com
  web
    nginx
      + Write the home page: file /var/www/staging.example.com/index.html
          create directory /var/www/staging.example.com (owner root, group root, mode 0755)
          owner root, group root, mode 0644
          @@ -0,0 +1,3 @@
          +<!doctype html>
          +<title>staging.example.com</title>
          +<p>Welcome to staging.example.com.</p>
      + Configure the site: file /etc/nginx/sites-enabled/staging.example.com
          owner root, group root, mode 0644
          @@ -0,0 +1,6 @@
          +server {
          +	listen 80;
          +	listen [::]:80;
          +	server_name staging.example.com;
          +	root /var/www/staging.example.com;
          +}
          validate: nginx -t
      ~ Remove the other sites: dir /etc/nginx/sites-enabled
          remove symbolic link /etc/nginx/sites-enabled/default
      ! handler nginx.reload

1 host: 1 to change, 0 unchanged, 0 unknown
plan 5303e943345da0fd
```

The plan shows the steps under the stage and the recipe. `!` marks the
handler that will run.

Apply it to staging:

```sh
winch apply site --inventory staging
```

Then apply it to production:

```sh
winch apply site --inventory production
```

```output
Apply these changes? [y/N] y
web1.example.com: nginx: + Write the home page: file /var/www/example.com/index.html
web1.example.com: nginx: + Configure the site: file /etc/nginx/sites-enabled/example.com
web1.example.com: nginx: ~ Remove the other sites: dir /etc/nginx/sites-enabled
web1.example.com: nginx: ~ handler nginx.reload: Reload nginx: service nginx

2 hosts: 1 changed, 1 unchanged
```

The old page `/var/www/html/index.html` stays on the server: winch
changes only what the steps declare. To remove it, add a step with
`absent: true`:

```yaml
- file:
    path: /var/www/html/index.html
    absent: true
```

Next: [HTTPS](../https/).
