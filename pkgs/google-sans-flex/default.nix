{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  # Google Sans Flex isn't in the github.com/google/fonts source repo;
  # it's only distributed via fonts.gstatic.com. URLs are content-addressed
  # and pinned to /v20/ — refresh via fonts.googleapis.com/css2 if Google
  # bumps the version.
  baseUrl = "https://fonts.gstatic.com/s/googlesansflex/v20";
  weights = [
    {
      style = "Thin";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp8uaycs.ttf";
      hash = "sha256:0s6vi4xn4as2hljvqs3a3nap3k3bg29hr3wqc1qddpp967ap94s5";
    }
    {
      style = "ExtraLight";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp0ubycs.ttf";
      hash = "sha256:171dm5slsmfghjbh9fkxaayz2lvvmqmnzjk2bass84qxhw9mpa26";
    }
    {
      style = "Light";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp5Wbycs.ttf";
      hash = "sha256:18cj9v57g8qqv3yzj5dgs3q9c9l5ax7h6r702gzx48c6q8j2frl3";
    }
    {
      style = "Regular";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp8ubycs.ttf";
      hash = "sha256:06myzvsr0vhiynfwr0g3khgrrdpm8p1x5dy6abg4asfbzy1sqxn0";
    }
    {
      style = "Medium";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp_mbycs.ttf";
      hash = "sha256:0xwfa6c8fp8ag6gbpiprnnk0sx1x47w0kngd95xsag3jfpjqh61z";
    }
    {
      style = "SemiBold";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakpxWcycs.ttf";
      hash = "sha256:0x7b7d51zp3s2klvqqnzkxxgcz9pspcgaigwwdb6v9aacjknrp70";
    }
    {
      style = "Bold";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakpyycycs.ttf";
      hash = "sha256:02ai8lgj3yf3wfnygg4r6v85ya63ch6sb8489x1lr27l66x6y4kp";
    }
    {
      style = "ExtraBold";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp0ucycs.ttf";
      hash = "sha256:08falnybadw853carmhzbschalbbcd6pvszgjqw8ara62abdmjp7";
    }
    {
      style = "Black";
      file = "t5sJIQcYNIWbFgDgAAzZ34auoVyXkJCOvp3SFWJbN5hF8Ju1x6sKCyp0l9sI40swNJwInycYAJzz0m7kJ4qFQOJBOjLvDSndo0SKMpKSTzwliVdHAy4bxTDHg_ugnAakp2Kcycs.ttf";
      hash = "sha256:0ggb5ll2idbgr1svms2k6bmsw638d7lhiapm3gr6rhqqhh7m8ic2";
    }
  ];

  sources = map (w: {
    inherit (w) style;
    src = fetchurl {
      url = "${baseUrl}/${w.file}";
      inherit (w) hash;
    };
  }) weights;

  installLines = lib.concatMapStringsSep "\n" (
    s: "install -Dm644 ${s.src} $out/share/fonts/truetype/GoogleSansFlex-${s.style}.ttf"
  ) sources;
in
stdenvNoCC.mkDerivation {
  pname = "google-sans-flex";
  version = "v20";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    ${installLines}
    runHook postInstall
  '';

  meta = {
    description = "Google Sans Flex variable font (static weight cuts from fonts.gstatic.com)";
    homepage = "https://fonts.google.com/specimen/Google+Sans+Flex";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
}
