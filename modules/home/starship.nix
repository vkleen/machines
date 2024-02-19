{ trilby, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = {
      character = {
        success_symbol = "[\\$](white)";
        error_symbol = "[\\$](red)";
        vicmd_symbol = "[\\$](green)";
      };
    } // lib.optionalAttrs (trilby.edition != "server") {
      character = {
        success_symbol = "[»](purple)";
        error_symbol = "[»](red)";
        vicmd_symbol = "[«](green)";
      };
      git_status = {
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        conflicted = "🏳";
        deleted = "🗑";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        modified = "📝";
        renamed = "👅";
        staged = "[++\(\${count}\)](green)";
        stashed = "📦";
        untracked = "🤷";
        up_to_date = "✓";
      };
    };
  };
}
