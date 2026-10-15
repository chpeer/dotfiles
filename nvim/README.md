# NeoVim config


To link the config:

```
ln -s $HOME/dev/dotfiles/nvim $HOME/.config/nvim
```

Software requirements:
* Neovim 0.12+
* Language servers as required (installed via Mason)
* fzf
* ripgrep (rg)
* `tree-sitter` CLI and a C compiler (nvim-treesitter parsers). Install via rustup + `cargo install --locked tree-sitter-cli` (enable the `rust` zsh module), not npm
* `make` (telescope-fzf-native, LuaSnip jsregexp)
* `dlv` (delve) for Go debugging with nvim-dap-go

Installing LSPs:

```
:Mason -> LSP -> `i`
```
