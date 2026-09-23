{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernel.sysctl = {
      "vm.dirty_background_bytes" = 268435456;
      "vm.dirty_bytes" = 2147483648;
      "vm.dirty_writeback_centisecs" = 100;
      "vm.dirty_expire_centisecs" = 1000;
    };
  };

  security.protectKernelImage = true;
}
