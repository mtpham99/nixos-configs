{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.hyprland;
in
{
  imports = [
    ./hyprlock.nix
    ./walker.nix
  ];

  options = {
    hyprland = {
      enable = lib.mkEnableOption "hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    home.packages = [
      pkgs.brightnessctl
      pkgs.wireplumber
      pkgs.xdg-utils
    ];

    hyprlock.enable = true;
    walker.enable = true;

    xdg.configFile."uwsm/env-hyprland".text = ''
      # gpu selection/priority
      # NOTE: using symlinks created by udev rules
      "AQ_DRM_DEVICES, /dev/dri/intel-uhd-graphics-630:/dev/dri/nvidia-gtx-1650-maxq"
    '';
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      settings = {
        monitor = ", preferred, auto, 2.0";
        # monitor = ", preferred, auto, 2.0, bitdepth, 10, cm, hdr";

        debug.disable_logs = false;
        general = {
          snap.enabled = true;
          allow_tearing = true;
          resize_on_border = true;
        };

        input = {
          # keyboard
          repeat_rate = 30;
          repeat_delay = 250;

          # mouse/touchpad
          accel_profile = "flat";
          sensitivity = 0.2;
          scroll_method = "2fg";
          touchpad.natural_scroll = true;
        };

        misc = {
          vrr = 3;
          force_default_wallpaper = 0;
          key_press_enables_dpms = true;
        };

        bind = [
          # exit
          "SUPER, BACKSPACE, killactive"
          "SUPER_ALT_CTRL, DELETE, exec, hyprctl dispatch exit"

          # lock
          "SUPER, ESC, exec, pidof hyprlock || hyprlock -q"

          # terminal
          "SUPER, T, exec, xdg-terminal-exec"

          # launcher
          "SUPER, R, exec, nc -U \${XDG_RUNTIME_DIR}/walker/walker.sock"

          # focus
          "SUPER, H, movefocus, l"
          "SUPER, L, movefocus, r"
          "SUPER, K, movefocus, u"
          "SUPER, J, movefocus, d"

          # workspaces
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"
          "SUPER, PAGE_UP, workspace, e-1"
          "SUPER, PAGE_DOWN, workspace, e+1"
          "SUPER_SHIFT, 1, movetoworkspace, 1"
          "SUPER_SHIFT, 2, movetoworkspace, 2"
          "SUPER_SHIFT, 3, movetoworkspace, 3"
          "SUPER_SHIFT, 4, movetoworkspace, 4"
          "SUPER_SHIFT, 5, movetoworkspace, 5"
          "SUPER_SHIFT, 6, movetoworkspace, 6"
          "SUPER_SHIFT, 7, movetoworkspace, 7"
          "SUPER_SHIFT, 8, movetoworkspace, 8"
          "SUPER_SHIFT, 9, movetoworkspace, 9"
          "SUPER_SHIFT, 0, movetoworkspace, 10"

          # special workspaces
          "SUPER, S, togglespecialworkspace, scratch"
          "SUPER_SHIFT, S, movetoworkspace, special:scratch"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow" # left click
          "SUPER, mouse:273, resizewindow" # right click
        ];

        binde = [
          "SUPER_SHIFT, H, resizeactive, -10 0"
          "SUPER_SHIFT, J, resizeactive, 0 10"
          "SUPER_SHIFT, K, resizeactive, 0 -10"
          "SUPER_SHIFT, L, resizeactive, 10 0"
        ];

        bindl = [
          ", switch:Lid Switch, exec, pidof hyprlock || hyprlock -q"
          ", switch:on:Lid Switch, exec, hyprctl keyword monitor\", disable\""
          ", switch:off:Lid Switch, exec, hyprctl keyword monitor\", preferred, auto, 2.0\""
          # ", switch:off:Lid Switch, exec, hyprctl keyword monitor\", preferred, auto, 2.0, bitdepth, 10, cm, hdr\""
        ];

        bindle = [
          # audio
          ", XF86AudioRaiseVolume, exec, wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          # brightness
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        windowrulev2 = [
          "float, title:^(Open File)(.*)$"
          "float, title:^(Open Folder)(.*)$"
          "float, title:^(Save As)(.*)$"
          "float, title:^(Select a File)(.*)$"
        ];
      };
    };
  };
}
