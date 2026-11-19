pkgs:
{
  heft = pkgs.callPackage ./heft {};
  herdr-autoname = pkgs.callPackage ./herdr-autoname {};
  herdr-recall = pkgs.callPackage ./herdr-recall {};
  mcp-gateway = pkgs.callPackage ./mcp-gateway {};
  redact-secrets = pkgs.callPackage ./redact-secrets {};
  winnow = pkgs.callPackage ./winnow {};
}
// import ./third-party pkgs
