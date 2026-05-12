{ lib, self }:
{
  colors = import ./colors lib;
  theme = import ./theme {
    inherit lib self;
    fallback = "default-dark";
  };
}
