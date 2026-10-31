# winch-web

The website of [winch](https://github.com/davidklassen/winch) at
[winchstack.app](https://winchstack.app/): the landing page and the
docs.

## Build

You need [Hugo](https://gohugo.io/) v0.169.0 and Go, which Hugo uses
to fetch the theme.

```
hugo server    # http://localhost:1313
hugo --gc      # build into public/
```

## Layout

| Path | Content |
| --- | --- |
| `content/_index.md` | The landing page. |
| `content/docs/_index.md` | The Quick Start, the first page of the docs. |
| `content/docs/user-guide/` | The User Guide. |
| `content/docs/_content.gotmpl` | The reference pages, made from `data/reference.json`. |
| `data/reference.json` | The output of `winch doc --json`. |
| `assets/samples/` | The config of the examples on the landing page. |
| `assets/styles/` | The styles; the colors come from the mote color scheme. |
| `layouts/` | The templates, on top of the [Hugo Book](https://github.com/alex-shpak/hugo-book) theme. |

The site also serves `llms.txt` and a Markdown copy of each docs page,
for coding agents.

## Reference

The reference pages describe a released winch. To update them, write
the data file with the winch of that release:

```
make reference WINCH=path/to/winch    # default: winch on PATH
```

## License

[Apache-2.0](LICENSE).
