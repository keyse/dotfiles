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
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # Pi Launcher and Azure Functions Core Tools ship from their owners' own
    # taps, not homebrew-core. Declaring the taps here keeps
    # `cleanup = "zap"` from untapping them.
    #
    # microsoft/aspire is deliberately NOT here. Its cask calls `write_file`
    # inside `postflight_steps`, which Homebrew 6.0.1 does not define, so
    # tapping it aborts the whole activation:
    #   Error: Cask 'aspire' definition is invalid:
    #     undefined method 'write_file' for an instance of
    #     Homebrew::InstallSteps::DSL
    # Until that cask works on current Homebrew, the Aspire CLI comes from
    # `dotnet tool install -g aspire.cli` instead, which home.sessionPath
    # already puts on PATH. Retry the cask once upstream fixes it.
    taps = [
      "kunchenguid/tap"
      "azure/functions"
    ];
    brews = [
      "gh"
      "herdr"
      # Fully qualified for the same tap-trust reason as the casks below.
      "azure/functions/azure-functions-core-tools@4"
    ];
    casks = [
      "wezterm"
      # The versioned cask, not plain `claude-code`. The plain cask follows
      # Anthropic's stable release channel, which can sit many builds behind
      # what is actually published - far enough to strand you below a version
      # floor a Claude Code feature needs. `claude-code@latest` tracks the
      # published releases instead. Do not simplify it back.
      "claude-code@latest"
      # Fully qualified so Homebrew trusts this non-official tap's cask
      # during activation (HOMEBREW_REQUIRE_TAP_TRUST).
      "kunchenguid/tap/pi-launcher"
    ];
  };
}
