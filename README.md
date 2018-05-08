# nixos-pure-rebuild

A script that wraps nixos-rebuild to make the build as pure as
possible. Now you can do reproduceable deployments such as:

```
nixos-pure-rebuild switch \
  --build-host localhost --target-host some-server \
  --nixpkgs-url https://github.com/NixOS/nixpkgs/archive/b0dac30ab552a59b772b4fe34c494b107fce01e5.tar.gz \
  --nixpkgs-sha256 064vg2m7n92spjzjck3hia38afjpv026641ih0jlh5knsjk099j0 \
  --nixos-config myserver_config.nix 
```
