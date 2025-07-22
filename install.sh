#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

echo "Installing dotfiles..."

# Create symlinks
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile" 
ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zfunc" "$HOME/.zfunc"

echo "Dotfiles installed!"
echo "Restart your shell or run: exec zsh"