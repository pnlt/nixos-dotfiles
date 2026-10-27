pkgs:
{
  hark = pkgs.callPackage ./hark {};
  heft = pkgs.callPackage ./heft {};
  herdr-autoname = pkgs.callPackage ./herdr-autoname {};
  herdr-recall = pkgs.callPackage ./herdr-recall {};
  mcp-gateway = pkgs.callPackage ./mcp-gateway {};
  redact-secrets = pkgs.callPackage ./redact-secrets {};
  barfeed = pkgs.callPackage ./barfeed {};
}
// import ./third-party pkgs
