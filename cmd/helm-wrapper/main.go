package main

import (
	"github.com/reddevs-io/kubernetes-binaries-managers/internal/wrapper"
)

func main() {
	var binName string = "helm"

	wrapper.Wrapper(binName)
}
