{
  inputs,
  den,
  ...
}: {
  perSystem = {pkgs, ...}: let
    diagram = inputs.den-diagram.lib;
    rc = diagram.renderContext {
      inherit pkgs;
    };
  in {
    # nix build .#den-namespace-svg
    packages.den-namespace-svg = rc.mmdSourceToSvg "den-namespace" (
      diagram.toMermaid
      (diagram.graph.ofNamespace {aspects = den.aspects;})
    );
  };
}
