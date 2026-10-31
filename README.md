# winch-web

The website of [winch](https://github.com/davidklassen/winch) at
[winchstack.app](https://winchstack.app/): the landing page and the
docs.

## Build

```
hugo server    # http://localhost:1313
hugo --gc      # build into public/
```

## Reference

The reference pages describe a released winch. To update them, write
the data file with the winch of that release:

```
make reference WINCH=path/to/winch    # default: winch on PATH
```

## License

[Apache-2.0](LICENSE).
