{}: ''
  // Main — left, landscape 2K 200Hz
  output "DP-2" {
      mode "2560x1440@200.000"
      scale 1.25
      transform "normal"
      position x=0 y=0
      focus-at-startup
  }

  // Secondary — right, portrait
  output "HDMI-A-1" {
      mode "1920x1080@74.973"
      scale 1
      transform "90"
      position x=2048 y=0
  }
''
