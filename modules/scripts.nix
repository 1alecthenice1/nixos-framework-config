{ pkgs, ... }: {
  environment.systemPackages = 
    let
      scriptNames = builtins.attrNames (builtins.readDir ./scripts);
      mkScriptBin = name: pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"));
    in
      builtins.map mkScriptBin scriptNames;
}