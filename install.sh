#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

echo "Installing dotfiles..."

# zsh
ln -sf "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile" 
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zfunc" "$HOME/.zfunc"

# starship
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# aerospace
mkdir -p "$HOME/.config/aerospace"
ln -sf "$DOTFILES_DIR/config/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"

# ghostty
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

# git 
mkdir -p "$HOME/.config/git"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

if [ -f "$DOTFILES_DIR/git/gitconfig-personal" ]; then
    ln -sf "$DOTFILES_DIR/git/gitconfig-personal" "$HOME/.config/git/gitconfig-personal"
fi

if [ -f "$DOTFILES_DIR/git/gitconfig-work" ]; then
    ln -sf "$DOTFILES_DIR/git/gitconfig-work" "$HOME/.config/git/gitconfig-work"
fi

echo "Dotfiles installed!"
echo "Restart your shell or run: exec zsh"