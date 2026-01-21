# Kubernetes Binaries Managers
Kubernetes related binaries manager.

[![License](https://img.shields.io/github/license/reddevs-io/kubernetes-binaries-managers.svg)](https://github.com/reddevs-io/kubernetes-binaries-managers/blob/master/LICENSE) [![Go Report Card](https://goreportcard.com/badge/github.com/reddevs-io/kubernetes-binaries-managers)](https://goreportcard.com/report/github.com/reddevs-io/kubernetes-binaries-managers) <a href='https://github.com/jpoles1/gopherbadger' target='_blank'>![gopherbadger-tag-do-not-edit](https://img.shields.io/badge/Go%20Coverage-79%25-brightgreen.svg?longCache=true&style=flat)</a>

## Installation

### Default Installation (All Binaries)

To install all Kubernetes binaries managers, run:

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash
```

### Selective Installation (Specific Binaries)

You can install specific binaries using the `-b` or `--binaries` flag followed by a comma-separated list of binaries:

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --binaries helmenv,kbenv
```

#### Available Binaries

- `helmenv` - Helm version manager
- `helm-wrapper` - Helm wrapper
- `kbenv` - kubectl version manager
- `kubectl-wrapper` - kubectl wrapper
- `ocenv` - oc version manager
- `oc-wrapper` - oc wrapper

#### Examples

Install only Helm-related tools:
```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --binaries helmenv,helm-wrapper
```

Install only kubectl-related tools:
```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --binaries kbenv,kubectl-wrapper
```

Install only OpenShift oc-related tools:
```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --binaries ocenv,oc-wrapper
```

### Help

To view available installation options:

```bash
curl -sSfL https://raw.githubusercontent.com/reddevs-io/kubernetes-binaries-managers/master/install.sh | bash -s -- --help
```

### Documentation

- [Kubectl version manager](./cmd/kbenv/README.md)

- [Helm version manager](./cmd/helmenv/README.md)

- [Openshitf's OC version manager](./cmd/ocenv/README.md)
