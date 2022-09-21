.PHONY := install say_hello
.DEFAULT_GOAL := help
CURRENT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install butler
	@[ -L "/usr/local/bin/butler" ] || sudo ln -s "$(CURRENT_DIR)/butler" "/usr/local/bin/butler"
	@sudo mkdir -p /etc/bash_completion.d
	@[ -L "/etc/bash_completion.d/butler" ] || sudo ln -s "$(CURRENT_DIR)/bin/autocomplete" "/etc/bash_completion.d/butler"


