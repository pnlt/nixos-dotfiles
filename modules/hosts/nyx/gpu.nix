{...}: {
  flake.modules.nixos.nyx = {config, ...}: {
    # Raw YAML: services.lact.settings quotes the integer fan curve keys, which LACT rejects.
    # Reference RX 6800 XT. Unstable at -175mV/2750MHz. VRAM 1075MHz flickered DP-2 on window close/hide.
    environment.etc."lact/config.yaml".text = ''
      version: 7
      daemon:
        log_level: info
        admin_group: wheel
        disable_clocks_cleanup: false
      apply_settings_timer: 5
      gpus:
        1002:73BF-1002:0E3A-0000:03:00.0:
          fan_control_enabled: true
          fan_control_settings:
            mode: curve
            static_speed: 0.5
            temperature_key: junction
            interval_ms: 500
            curve:
              55: 0.22
              70: 0.32
              80: 0.45
              90: 0.62
              100: 0.8
              105: 1.0
            spindown_delay_ms: 3000
            change_threshold: 2
          power_cap: 293.0
          performance_level: manual
          max_core_clock: 2700
          max_memory_clock: 1000
          voltage_offset: -150
      current_profile: null
      auto_switch_profiles: false
    '';

    systemd.services.lactd.restartTriggers = [config.environment.etc."lact/config.yaml".source];
  };
}
