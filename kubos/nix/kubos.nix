{pkgs, ...}: let
  kubosSrc = pkgs.fetchFromGitHub {
    owner = "kubos";
    repo = "kubos";
    rev = "1.20.0";
    sha256 = "sha256-6W0jajysH1den4TswDwNq6HUOLABprJZ80ZzReripLQ=";
  };
in rec {
  app_api = py:
    py.buildPythonPackage {
      pname = "app_api";
      version = "0.1.0";
      src = kubosSrc;
      sourceRoot = "source/apis/app-api/python";
      propagatedBuildInputs = [
        py.mock
        py.requests
        py.setuptools
        py.toml
        (responses py)
      ];
      checkInputs = [py.six];
    };
  kubos_service = py:
    py.buildPythonPackage {
      pname = "kubos_service";
      version = "1.0.0";
      src = kubosSrc;
      sourceRoot = "source/libs/kubos-service";
      doCheck = false;
      propagatedBuildInputs = [
        py.flask
        (flask-graphql py)
        (graphene py)
        py.toml
      ];
    };
  responses = py:
    py.buildPythonPackage rec {
      pname = "responses";
      version = "0.10.6";
      src = py.fetchPypi {
        inherit pname version;
        sha256 = "sha256-UC2cDIAIQ5z83vfiUfUH/P3VA7VujAyHw8PjOTlT95A=";
      };
      propagatedBuildInputs = [py.pip];
      doCheck = false;
    };
  flask-graphql = py:
    py.buildPythonPackage rec {
      pname = "Flask-GraphQL";
      version = "1.4.1";
      src = py.fetchPypi {
        inherit pname version;
        sha256 = "sha256-hL5y1rD4HcD7nSF3/AIiqIX4XYTaTOdVlyyha+QTt7w=";
      };
      propagatedBuildInputs = [
        py.pip
        (graphql-core py)
      ];
      checkInputs = [py.six];
      doCheck = false;
    };
  graphql-core = py:
    py.buildPythonPackage rec {
      pname = "graphql-core";
      version = "1.1";
      src = py.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Y7uFk67q2wpT4UIHuRACf+URWNAXkn+thzJtrIBhhe4=";
      };
      propagatedBuildInputs = [py.pip];
      checkInputs = [py.six py.promise];
      doCheck = false;
    };
  graphene = py:
    py.buildPythonPackage rec {
      pname = "graphene";
      version = "2.1.1";
      src = py.fetchPypi {
        inherit pname version;
        sha256 = "sha256-dsZw9hhOsxHJ9KI7dw8RSqAy5C7v5QmhCjBuF0X3BAc=";
      };
      propagatedBuildInputs = [
        py.pip
        (graphql-relay py)
      ];
    };
  graphql-relay = py:
    py.buildPythonPackage rec {
      pname = "graphql-relay";
      version = "0.4.5";
      src = py.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Jxa3JF2XCRryGr8Jb6uvrFdpBQltIbpxGPunIllvZds=";
      };
      propagatedBuildInputs = [py.pip];
      doCheck = false;
    };
}
