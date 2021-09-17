{
  description = "Python OTR implementation; it does not bind to libotr";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.python-otr={url=github:python-otr/pure-python-otr; flake=false;};
  outputs = { self, nixpkgs,python-otr}:
    let


      supportedSystems = [ "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

          python-otr = with final; python38.pkgs.buildPythonPackage rec {
          pname = "python-otr";
          version = "1.0.2";
        
          src = python-otr;
        
          buildInputs = with  python38Packages; [
           pycrypto 
          ];
 
          checkInputs = with python38Packages; [
            nose
            rednose
          ];
          doCheck=false;
          /*
          Tests are broken https://github.com/python-otr/pure-python-otr/issues/75
          */
          checkPhase = ''
            ls -l
            SRC_ROOT=$(cd -P $(dirname "$0") && pwd)
            export PYTHONPATH=$PYTHONPATH:"$SRC_ROOT/src"

            nosetests --rednose --verbose
          '';
        
        
          meta = with lib; {
            description = "Pure python OTR Implementaion";
            homepage = https://github.com/python-otr/pure-python-otr;
            license = licenses.lgpl2Plus;
          };
        };
      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) python-otr;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.python-otr);



    };
}
