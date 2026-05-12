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

  readMatugen =
    { file }:
    if !builtins.pathExists file then
      null
    else
      let
        r = builtins.tryEval (builtins.fromJSON (builtins.readFile file));
      in
      if r.success then r.value else null;
}
