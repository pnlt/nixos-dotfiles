{pkgs, ...}: {
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

  # Useful checks / tools (optional)
  environment.systemPackages = with pkgs; [
    vulkan-tools # vulkaninfo
    mesa-demos
    # lact       # GUI fan/OC — enable service below if you use it
  ];

  # Optional: AMD control panel (fans, power limit, mild OC)
  # services.lact.enable = true;
}
