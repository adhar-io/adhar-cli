// Package main represents the main entrypoint of the go-starter application.
package main

import (
	"log"

	"github.com/adhar-io/adhar-cli/cmd"
)

// main will start the go-starter command lifecycle and spawn the go-starter services.
func main() {
	err := cmd.Execute()
	if err != nil {
		log.Println("Unable to execute root command:", err)
	}
}
