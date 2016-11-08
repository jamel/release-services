{ releng_pkgs, python, extras }:

let

  inherit (releng_pkgs.pkgs.lib) fileContents optionals;
  inherit (releng_pkgs.lib) filterSource;

  version = fileContents ./../../VERSION;
  name = "releng-common";

in python.mkDerivation {
  name = "${name}-${version}";
  src = filterSource ./. { inherit name; };
  buildInputs =
    [ python.packages."flake8"
    ];
  propagatedBuildInputs =
    [ python.packages."Flask"
      python.packages."Jinja2"
    ] ++ optionals (builtins.elem "cache" extras) [ python.packages."Flask-Cache" ]
      ++ optionals (builtins.elem "db" extras) [ python.packages."Flask-SQLAlchemy" python.packages."Flask-Migrate" ]
      ++ optionals (builtins.elem "auth" extras) [ python.packages."Flask-Login" python.packages."taskcluster" ]
      ++ optionals (builtins.elem "api" extras) [ python.packages."connexion" ]
      ++ optionals (builtins.elem "log" extras) [ python.packages."structlog" ]
      ++ optionals (builtins.elem "cors" extras) [ python.packages."Flask-Cors" ];
  checkPhase = ''
    flake8 --exclude=nix_run_setup.py,migrations/,build/
    # TODO: py.test
  '';
  patchPhase = ''
    rm VERSION
    echo ${version} > VERSION
  '';
}
