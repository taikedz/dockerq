#!/usr/bin/env bash

bins="$HOME/.local/bin/"
if [[ "$UID" = 0 ]]; then
	bins=/usr/local/bin
fi

[[ -d "$bins" ]] || mkdir -p "$bins"

cp bin/dockerq "$bins"

echo "'dockerq' is now installed"
