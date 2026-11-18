fzf_theme_opts="\
--color=bg+:#201f25
--color=bg:#141318
--color=spinner:#e6e1e9
--color=hl:#ffb4ab
--color=fg:#e6e1e9
--color=header:#ffb4ab
--color=info:#c9beff
--color=pointer:#e6e1e9
--color=marker:#c9c5d0
--color=fg+:#e6e1e9
--color=prompt:#c9beff
--color=hl+:#ffb4ab
--color=selected-bg:#48454e
--color=border:#48454e
--color=label:#e6e1e9"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"
