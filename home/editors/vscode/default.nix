{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    # Let HM install vscode
    package = pkgs.vscode;

    # Install extensions
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
    ];

    profiles.default = {
      userSettings = {
        # Disable AI
        "chat.disableAIFeatures" = true;
        "chat.commandCenter.enabled" = false;

        # Window
        "window.commandCenter" = false;
        "window.menuBarVisibility" = "toggle";
        "window.titleBarStyle" = "native";

        # Workbench
        "workbench.navigationControl.enabled" = false;
        "workbench.layoutControl.enabled" = false;
        "workbench.editor.enablePreview" = false;
        "workbench.activityBar.location" = "default";

        # Theme / Icons
        "workbench.colorTheme" = "Catppuccin Frappé";
        "catppuccin.accentColor" = "blue";
        "workbench.iconTheme" = "charmed-soft";
        "workbench.productIconTheme" = "icons-carbon";

        # Editor
        "editor.fontSize" = 14;
        "editor.fontFamily" = "JetBrains Mono";
        "editor.tabSize" = 2;
        "editor.lineHeight" = 22;
        "editor.folding" = true;

        "editor.cursorStyle" = "line-thin";
        "editor.cursorBlinking" = "phase";
        "editor.cursorSmoothCaretAnimation" = "on";

        "editor.smoothScrolling" = true;
        "editor.renderWhitespace" = "none";
        "editor.renderLineHighlight" = "all";

        "editor.semanticHighlighting.enabled" = true;
        "editor.occurrencesHighlight" = "singleFile";
        "editor.minimap.enabled" = false;

        "editor.scrollbar.verticalScrollbarSize" = 15;
        "editor.scrollbar.horizontalScrollbarSize" = 15;

        # Terminal
        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.minimumContrastRatio" = 1;
        "terminal.integrated.cursorStyle" = "line";
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.initialHint" = false;
      };
    };
  };
}
