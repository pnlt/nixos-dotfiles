pkgs:
{
  hark = pkgs.callPackage ./hark {};
  heft = pkgs.callPackage ./heft {};
  herdr-autoname = pkgs.callPackage ./herdr-autoname {};
  herdr-recall = pkgs.callPackage ./herdr-recall {};
  mcp-gateway = pkgs.callPackage ./mcp-gateway {};
  barfeed = pkgs.callPackage ./barfeed {};
}
// import ./third-party pkgs
