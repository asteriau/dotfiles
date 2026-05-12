{
  lib,
  self,
  profile,
}:
{
  colors = import ./colors lib;
  theme = import ./theme {
    inherit lib self profile;
    fallback = "default-dark";
  };
}
