{...}: {
  flake.modules.nixos.hardware = {pkgs, ...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.amdgpu = {
      # Load amdgpu early for cleaner modeset (optional but nice on discrete AMD)
      initrd.enable = true;
    };

    environment.variables = {
      # Prefer Mesa RADV (best default for gaming on AMD)
      AMD_VULKAN_ICD = "RADV";
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools # vulkaninfo
      mesa-demos
    ];
  };
}
