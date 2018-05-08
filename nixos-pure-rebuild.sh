#! /bin/sh

set -e
set -u
set -x

showSyntax() {
    cat <<EOF
Usage: $0 [OPTIONS...] OPERATION
This script is a thin wrapper around nixos-rebuild, it just adds two
additional options.

Options:
  --nixpkgs-url <PATH>
  --nixpkgs-sha256 <SHA256>
  --nixos-config <CONFIG>

EOF
    exit 1
}


# Parse the command line.
passThroughFlags=()
nixpkgsUrl=
nixpkgsSha256=
nixosConfig=

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      --help)
        showSyntax
        ;;
      --nixpkgs-url)
        nixpkgsUrl="$1"; shift 1
        ;;
      --nixpkgs-sha256)
        nixpkgsSha256="$1"; shift 1
        ;;
      --nixos-config)
        nixosConfig="$1"; shift 1
        ;;
      *)
        passThroughFlags+=("$i")
        ;;
    esac
done

if [ -z "$nixpkgsUrl" ]; then showSyntax; fi
if [ -z "$nixpkgsSha256" ]; then showSyntax; fi
if [ -z "$nixosConfig" ]; then showSyntax; fi


tempdir=$(mktemp -d)

cleanup () {
   rm -rf "$tempdir"
}
trap cleanup EXIT


cat <<EOF > $tempdir/nixpkgs.nix
let 
  nixpkgsStr = builtins.fetchTarball {url = "$nixpkgsUrl"; sha256 = "$nixpkgsSha256";};
  pkgs = (import nixpkgsStr) {};
in
  pkgs.runCommand "nixpkgs" {} ''
    ln -sv \${nixpkgsStr} \$out
  ''
EOF

nix build -f $tempdir/nixpkgs.nix -o $tempdir/nixpkgs

nixPkgsRealPath=$(realpath $tempdir/nixpkgs)
nixosConfigRealPath=$(realpath $nixosConfig)

export NIX_PATH="nixos-config=$nixosConfigRealPath:nixpkgs=$nixPkgsRealPath"

set +e
nixos-rebuild ${passThroughFlags[@]}
rc=$?
set -e

exit $rc