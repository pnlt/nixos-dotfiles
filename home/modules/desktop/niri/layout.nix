{}: ''
  layout {
      gaps 16
      center-focused-column "never"
      background-color "#1a1b26"

      preset-column-widths {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
          width 4
          active-color "#07b5ef"
          inactive-color "#ffffff00"
          active-gradient from="#f00f" to="#0f05" angle=45 in="oklch longer hue"
      }

      border {
          off
      }

      shadow {
          on
          draw-behind-window false
          softness 40
          spread 5
          offset x=0 y=5
          color "#0007"
      }
  }

  prefer-no-csd

  overview {
      backdrop-color "#1a1b26"
      workspace-shadow {
          softness 50
          spread 20
          offset x=0 y=10
          color "#0007"
      }
  }

  clipboard {
      disable-primary
  }
''
