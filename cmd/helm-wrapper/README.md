# Helm Wrapper

This is a helm wrapper. It doesn't do much more than execute every command as
is. The only special thing it does is to choose which version to use. Just use
it as a substitute of the binary. Please refer to
[helmenv](../helmenv/README.md).

## Installation

The `helm-wrapper` is typically installed alongside `helmenv`. While you can install just `helmenv`, the wrapper provides the seamless experience of using `helm` commands directly.

### Install helmenv with the wrapper

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --binaries helmenv,helm-wrapper
```

### Install all binaries (includes helm-wrapper)

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash
```

The wrapper will be installed as `helm` in your `~/.bin/` directory, allowing you to use `helm` commands naturally while benefiting from version management provided by `helmenv`.

For more details on usage, see the [helmenv documentation](../helmenv/README.md).
