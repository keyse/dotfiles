{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # The Aspire CLI and Pi Launcher ship from their owners' own taps, not
    # homebrew-core. Declaring the taps here keeps `cleanup = "zap"` from
    # untapping them.
    taps = [
      "microsoft/aspire"
      "kunchenguid/tap"
    ];
    brews = [
      "herdr"
    ];
    casks = [
      "wezterm"
      "claude-code"
      # Fully qualified so Homebrew trusts these non-official taps' casks
      # during activation (HOMEBREW_REQUIRE_TAP_TRUST).
      "microsoft/aspire/aspire"
      "kunchenguid/tap/pi-launcher"
    ];
  };
}
