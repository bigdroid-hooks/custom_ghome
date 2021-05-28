#!/usr/bin/env bash

BT="$TMP_DIR/add_custom_ghome"

# Setup
if test -e "$BT"; then
	rm -rf "$BT"
fi
mkdir -p "$BT"

gclone "$HOOK_BASE/ghome" "$BT"

# Handle enc
readarray -d '' encrypted_files < <(find "$BT" -name "*.enc" -print0)
read -p 'Encrypt add_custom_ghome? [y/n]' ENC
if test "${ENC,,}" == "n"; then
	for f in "${encrypted_files[@]}"; do
		rm "$f"
	done
else
	for f in "${encrypted_files[@]}"; do
		mv "$f" "${f%.enc}"
	done
fi

# Package assets
cd "$BT/ghome/dependencies/assets"
garca a -mx=${1:-"10"} -m0=zstd -mhe=on -p'017277axzpqr' ../distroinit_assets.gxp *
rm -r "$BT/ghome/dependencies/assets"
chmod -R 755 "$BT"
cd "$HOOK_BASE"

gclone "$BT/ghome/" "$GHOME"
cd "$GBDIR/boot-comp"
test "$DISTRO_NAME" == "PrimeOS" && {
	mv rusty-panda_$HOST_ARCH rusty-panda && rm rusty-panda_*
}
rm -r "$BT"
chown root:root -hR "$GHOME"
