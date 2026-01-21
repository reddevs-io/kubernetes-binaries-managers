# OC Wrapper

This is a OC wrapper. It doesn't do much more than execute every command as
is. The only special thing it does is to choose which version to use. Just use
it as a substitute of the binary. Please refer to [ocenv](../ocenv/README.md).

## Installation

The `oc-wrapper` is typically installed alongside `ocenv`. While you can install just `ocenv`, the wrapper provides the seamless experience of using `oc` commands directly.

### Install ocenv with the wrapper

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/main/install.sh | bash -s -- --binaries ocenv,oc-wrapper
```

### Install all binaries (includes oc-wrapper)

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/main/install.sh | bash
```

The wrapper will be installed as `oc` in your `~/.bin/` directory, allowing you to use `oc` commands naturally while benefiting from version management provided by `ocenv`.

For more details on usage, see the [ocenv documentation](../ocenv/README.md).
