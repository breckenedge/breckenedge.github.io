#!/bin/sh
# SSH setup for the devcontainer.
#
# The VS Code Dev Containers extension forwards the host's SSH *agent* into the
# container automatically (SSH_AUTH_SOCK is already set), on any host OS, so
# private keys never enter the container and you do NOT bind-mount ~/.ssh.
# (Bind-mounting is also outright broken on Windows hosts: Docker mounts the
# path 0777 and OpenSSH refuses world-writable keys. See issue #33.)
#
# So there's almost nothing to do here. This script just makes ~/.ssh sane and
# pre-trusts github.com so the first git push doesn't hang on a prompt. It is
# idempotent and safe to re-run on every rebuild.
set -e

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/known_hosts" ] || ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
  ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
  chmod 644 "$HOME/.ssh/known_hosts"
fi

# Sanity check (non-fatal): show whether the forwarded agent has any identities.
if [ -n "$SSH_AUTH_SOCK" ]; then
  ssh-add -l >/dev/null 2>&1 \
    && echo "SSH agent forwarded with identities available." \
    || echo "SSH agent forwarded but no identities loaded yet (run 'ssh-add' on the host)."
else
  echo "No SSH agent forwarded (SSH_AUTH_SOCK unset) - git over SSH may not work."
fi
