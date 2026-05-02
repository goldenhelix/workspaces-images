# Golden Helix Fork of `kasmtech/workspaces-images`

This repo builds the **app-layer** images that derive from
`ghdesktop-core` — `ghdesktop-office-web` (chromium + onlyoffice +
vscode) and `ghdesktop-varseq` (VarSeq baked in for testing).

## What this repo IS

A fork of `kasmtech/workspaces-images` (originally Ubuntu-based) that
we've trimmed down to just the apps we need, on top of our
`ghdesktop-core-trixie` base.

## Branch and pinning

- Long-lived branch: **`goldenhelix-master-20260430`** in
  `goldenhelix/workspaces-images` (after fork).
- Forked from `kasmtech/workspaces-images` `develop`.

## Repo structure

```
dockerfile-gh-office-web         ← chromium + onlyoffice + vscode on top of core
dockerfile-gh-varseq-bake        ← bakes a local VarSeq tarball in (for testing)
build-trixie.sh                  ← builds office-web on the trixie core
build-varseq-trixie.sh           ← builds varseq image on the trixie office-web

src/
  varseq/varseq.tar.gz           ← staged VarSeq tarball (bake-into-image flow)
  ubuntu/install/                ← upstream Kasm install scripts (chromium, only_office, vs_code)
```

The "real" production VarSeq image is built by `varseq/server/build/`
in the VarSeq repo (downloads VarSeq from the goldenhelix proxy at
build time). The `dockerfile-gh-varseq-bake` here is a local-test
variant — copies a pre-downloaded tarball straight into the image so
you can iterate without re-downloading 380 MB.

## What we override vs upstream

### `dockerfile-gh-office-web`

- **`BASE_IMAGE` arg** — defaults to `ghdesktop-core` but build
  scripts override to `ghdesktop-core-trixie`.
- **Adds `curl ca-certificates sudo`** — trixie-slim cleanup strips
  these and the upstream chromium / only_office / vs_code installers
  shell out to them.
- **chmod +x on panel launcher and Desktop .desktop files** — XFCE
  4.18+ refuses to launch unmarked-executable .desktop files
  (combined with gio metadata::xfce-exe-checksum seeded at session
  start in vnc_startup.sh).
- **Pre-configures VS Code argv.json** with
  `{"password-store": "basic"}` — stops VSCode prompting to create a
  new gnome-keyring on first launch.
- **Re-runs `gtk-update-icon-cache`** at the end of the office-web
  build for `/usr/share/icons/elementary-xfce` and
  `/usr/share/icons/hicolor`. The chromium / vs_code / only_office
  install scripts each do `find /usr/share -name icon-theme.cache
  -delete` as part of cleanup, which nukes what the core image
  generated.

### `dockerfile-gh-varseq-bake`

- Test-only image: copies `src/varseq/varseq.tar.gz` straight into the
  layer rather than fetching it. Useful for iterating against a
  specific dev build without waiting for the proxy round trip.
- Generates `/usr/share/applications/varseq.desktop` inline (the
  production `varseq/server/build/varseq/install_varseq.sh` does the
  same thing but downloads the tarball + icon over the network).
- Fills the panel slot at `~/.config/xfce4/panel/launcher-5/17306804705.desktop`
  (the slot reserved for VarSeq in the core image's launcher).

## Build sequence

```sh
# Prerequisites: ghdesktop-core-trixie:latest must exist locally
# (see ../appstream-core-images/build-trixie.sh).

cd ../appstream-images

# 1. office-web on top of core
./build-trixie.sh
# → registry.goldenhelix.com/public/ghdesktop-office-web-trixie:latest

# 2. (optional, for local testing) bake-in varseq variant
cp /mnt/mindshare/Products/Builds/Installers/VarSeq-Lin64-3.1.0-DEV5.tar.gz \
   src/varseq/varseq.tar.gz
./build-varseq-trixie.sh
# → registry.goldenhelix.com/public/ghdesktop-varseq-trixie:latest
```

For the **production VarSeq build** (downloaded from proxy), use
`varseq/server/build/build.mjs` with
`--build-arg BASE_IMAGE=ghdesktop-office-web-trixie`.

## Variants we used to maintain (and dropped)

- `build_core.sh` (bookworm office-web) — original, dropped.
- `build-jammy.sh`, `build-varseq-jammy.sh` (Ubuntu 22.04) — worked
  but no longer the target.
- `build-varseq-noble.sh` (Ubuntu 24.04) — worked, same caveats as
  noble core.

These build scripts may still be present; safe to delete in a future
cleanup. **Trixie is the only target we test against now.**
