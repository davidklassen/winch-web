{{- range site.Params.install }}
{{ .name }}:

```sh
{{ .command }}
```
{{ end -}}
