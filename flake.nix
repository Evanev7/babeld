{
  description = "C Template";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        pname = "babeld";
        version = "1.13.1";
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          inherit pname version;

          src = pkgs.fetchurl {
            url = "https://www.irif.fr/~jch/software/files/${pname}-${version}.tar.gz";
            hash = "sha256-FfJNJtoMz8Bzq83vAwnygeRoTyqnESb4JlcsTIRejdk=";
          };

          outputs = [
            "out"
            "man"
          ];

          makeFlags = [
            "PREFIX=${placeholder "out"}"
            "ETCDIR=${placeholder "out"}/etc"
          ]
          ++ pkgs.lib.optional pkgs.stdenv.isDarwin "LDLIBS=''";
        };
      }
    );
}
