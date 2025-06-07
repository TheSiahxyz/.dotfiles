FROM debian:latest

ARG NAME=toolbox

LABEL name="$NAME" \
  summary="Debian toolbox container" \
  maintainer="TheSiahxyz"

ENV EDITOR=nvim

ENV NODE_VERSION=21.7.1

ENV BASE_USER=si

ENV PASSWORD=password

ENV HOME=/home/$BASE_USER

RUN apt update && apt -y upgrade && apt -y install sudo

RUN useradd -m -G wheel $BASE_USER

RUN echo "$BASE_USER:$PASSWORD" | chpasswd

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $BASE_USER

WORKDIR /home/$BASE_USER

ENV PATH=$PATH:$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:$HOME/.cargo/bin

RUN sudo apt -y upgrade \
  && sudo apt -y install \
  tmux \
  ruby \
  php-common \
  php-cli \
  luarocks \
  curl \
  python3 \
  python3-pip \
  java-latest-openjdk-devel \
  ripgrep \
  fd-find \
  git \
  neovim \
  golang \
  cargo \
  composer \
  julia-devel \
  lua5.1 \
  stow \
  && sudo apt clean all

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

ENV NVM_DIR="$HOME/.nvm"

RUN . $HOME/.nvm/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSON \
  && nvm use default \
  && . $HOME/.nvm/bash_completion

ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules

RUN pip3 install pynvim

RUN mkdir $HOME/.npm-global && npm config set prefix '~/.npm-global' \
  && echo "export PATH=$HOME/.npm-global/bin:$PATH" >> $HOME/.profile && source $HOME/.profile

RUN npm install -g neovim

RUN go install github.com/jesseduffield/lazygit@latest

RUN cargo install tree-sitter-cli

RUN git clone https://github.com/TheSiahxyz/.dotfiles.git

RUN npm install -g eslint_d

RUN nvim --headless "+Lazy! sync" +qa

RUN nvim --headless "+MasonInstall codelldb delve gopls clangd lua-language-server pyright rust-analyzer typescript-language-server eslint_d flake8 black gofumpt prettier stylua clang-format" +qa

RUN sudo cp -f /usr/bin/lua-5.1 /usr/bin/lua

RUN sudo rm -rf /usr/lib64/nvim/parser

RUN sudo luarocks install jsregexp

COPY ./.tmux.conf /home/$BASE_USER/.tmux.conf

RUN sudo chown si:si /home/$BASE_USER/.tmux.conf

RUN wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip \
  && cd ~/.local/share/fonts \
  && unzip FiraCode.zip \
  && rm FiraCode.zip \
  && fc-cache -fv

RUN cargo install starship --locked \
  && echo 'eval "$(starship init bash)"' >> ~/.bashrc

CMD tmux
