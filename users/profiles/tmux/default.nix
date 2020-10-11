{ config, pkgs, ... }:
{
  home.file.".tmux.conf".text = ''
    set -g exit-unattached off
    set -g default-shell ${pkgs.zsh}/bin/zsh
    set -g allow-rename off

    set -g base-index 1
    set -g pane-base-index 1

    set -ga terminal-overrides ",xterm-256color:Tc"
    set -g default-terminal "tmux-256color"

    set -ga update-environment 'WAYLAND_DISPLAY SWAYSOCK'

    set -g mouse on
    set -g status off
    set -g status-left " "
    set -g status-right " "
    set -g status-justify centre

    set -gw window-status-current-format "#{window_index}:#{=10:window_name}"
    set -gw window-status-format "#{window_index}:#{=10:window_name}#{window_flags}"
    set -gw mode-style fg='#bbc2cf',bg='#3f444a'

    set -g message-style fg='#da8548',bg='#282c34'
    set -g status-style bg='#282c34'
    set -g window-status-style fg='#bbc2cf'
    set -g window-status-current-style fg='#b58900'

    set -g pane-active-border-style fg='#51afef'
    set -g pane-border-style fg='#282c34'

    setw -g mode-keys vi

    set -g escape-time 0

    set-window-option -g aggressive-resize on

    set -g bell-action none
    set -g visual-bell off
    set -g activity-action none
    set -g silence-action none

    set -g history-limit 100000


    unbind C-b
    set -g prefix C-Space
    bind b send-prefix

    bind-key r source-file ~/.tmux.conf \; display "Config reloaded!"

    bind C-Space copy-mode

    bind j split-window -v -c "#{pane_current_path}"
    bind C-j split-window -v -c "#{pane_current_path}"

    bind l split-window -h -c "#{pane_current_path}"
    bind C-l split-window -h -c "#{pane_current_path}"

    bind-key q kill-window
    bind-key C-q kill-window

    bind-key x kill-pane
    bind-key C-x kill-pane

    bind-key c new-window -c "#{pane_current_path}"

    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
    bind-key p run "${pkgs.wl-clipboard}/bin/wl-paste -n | tmux load-buffer - ; tmux paste-buffer -d"
  '';

  home.file.".terminfo/t/tmux-256color".source = ./tmux-256color;

  home.packages = with pkgs; [
    tmux
  ];
}
