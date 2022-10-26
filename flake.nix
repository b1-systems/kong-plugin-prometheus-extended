{
  description = "Kong plugin development environment";

  inputs = {
    utils.url = "github:numtide/flake-utils";

    pongo = {
      type = "github";
      owner = "Kong";
      repo = "kong-pongo";
      ref = "1.3.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, pongo }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = utils.lib.flattenTree {
          deck = pkgs.buildGoModule rec {
            pname = "deck";
            version = "1.5.1";

            src = pkgs.fetchFromGitHub {
              owner = "Kong";
              repo = pname;
              rev = "v${version}";
              sha256 = "sha256-r4Oqzs502iKBJL2/GhQBh7tESRE+vMaXZfzLfXknKyM=";
            };

            vendorSha256 =
              "sha256-W54z9j8NTQYdM/HvETpKGcfAI5xMJbzurcK7UcNNrZQ=";

            excludedPackages = [ ];

            ldflags = [ "-s" "-w" "-X main.version=v${version}" ];
          };

          pongo = pkgs.writeShellApplication {
            name = "pongo";
            text = ''
              ${pongo.outPath}/pongo.sh "$@"
            '';
          };
        };

        # defines a development environment with pongo available
        # preferably use direnv to activate
        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [ cassowary curl docker-compose_2 fx jq pgcli ]
            ++ [ packages.deck packages.pongo ] ++ (with pkgs.luaPackages; [
              luarocks
              luacov
              luacheck
              luaformatter
            ]);
        };
      });
}
