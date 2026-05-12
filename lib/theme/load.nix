{ lib }:
{
  loadPreset =
    {
      dir,
      name,
    }:
    let
      path = "${dir}/${name}.json";
    in
    if !builtins.pathExists path then
      throw "theme: preset '${name}' not found at ${path}"
    else
      builtins.fromJSON (builtins.readFile path);

  readActivePreset =
    {
      file,
      fallback,
    }:
    if builtins.pathExists file then
      lib.strings.removeSuffix "\n" (builtins.readFile file)
    else
      fallback;
}
