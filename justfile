CURRENT_DIR := justfile_directory()

# Display available commands
help:
    @just --list

# Install butler and git hooks
install:
    @[ -L "/usr/local/bin/butler" ] \
        || sudo ln -s "{{CURRENT_DIR}}/butler" "/usr/local/bin/butler"
    @sudo mkdir -p /etc/bash_completion.d
    @[ -L "/etc/bash_completion.d/butler" ] \
        || sudo ln -s "{{CURRENT_DIR}}/bin/autocomplete" "/etc/bash_completion.d/butler"
    lefthook install
    @echo "Butler installed. Run 'butler' anywhere."

# Format all shell scripts
fmt:
    shfmt -w -i 2 butler bin/ scripts/

# Lint all shell scripts and markdown
lint:
    find . -name '*.sh' -o -name 'butler' | grep -v '.git' | xargs shellcheck -x
    markdownlint-cli2 "**/*.md"

# Run test suite
test:
    bats tests/
