# Kubectl Wrapper

This is a kubectl wrapper. It doesn't do much more than execute every command as
is. The only special thing it does is to choose which version to use. Just use
it as a substitute of the binary. Please refer to [kbenv](../kbenv/README.md).

## Installation

The `kubectl-wrapper` is typically installed alongside `kbenv`. While you can install just `kbenv`, the wrapper provides the seamless experience of using `kubectl` commands directly.

### Install kbenv with the wrapper

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/main/install.sh | bash -s -- --binaries kbenv,kubectl-wrapper
```

### Install all binaries (includes kubectl-wrapper)

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/main/install.sh | bash
```

The wrapper will be installed as `kubectl` in your `~/.bin/` directory, allowing you to use `kubectl` commands naturally while benefiting from version management provided by `kbenv`.

For more details on usage, see the [kbenv documentation](../kbenv/README.md).
