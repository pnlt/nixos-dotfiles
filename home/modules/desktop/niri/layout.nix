{}: ''
  layout {
      gaps 16
      center-focused-column "never"
      background-color "#0e0e0e"

      preset-column-widths {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
          width 2
          active-color "#e1e1e1cc"
          inactive-color "#ffffff00"
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
      backdrop-color "#0e0e0e"
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
