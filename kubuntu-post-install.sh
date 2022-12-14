#!/usr/bin/env bash
# ----------------------------- VARIÁVEIS ----------------------------- #

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_DISCORD="https://discord.com/api/download?platform=linux&format=deb"
URL_VSCODE="https://az764295.vo.msecnd.net/stable/5235c6bb189b60b01b1f49062f4ffa42384f8c91/code_1.74.0-1670260027_amd64.deb"
URL_ZOOM="https://zoom.us/client/5.12.9.367/zoom_amd64.deb"
URL_MYSQL_WORKBENCH_UBUNTU_2204="https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-dbgsym_8.0.31-1ubuntu22.04_amd64.deb"
URL_ZSHRC_FILE="https://raw.githubusercontent.com/juliana-ribeiro/linux-kubuntu-post-install/master/.zshrc"

DIR_PACOTES_DEB="$HOME/Downloads/Deb"
DIR_DOWNLOADS="$HOME/Downloads"

PACOTES_PARA_INSTALAR=(
  nvidia-driver-390
  zsh
  git
  apt-transport-https
  ca-certificates
  gnupg
  lsb-release
  docker-ce
  docker-ce-cli
  containerd.io
)
# ---------------------------------------------------------------------- #

# ----------------------------- INSTALAÇÃO ----------------------------- #

## Removendo travas do apt ##
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock

## Atualizando o repositório ##
sudo apt update -y
  
## Download de pacotes externos ##
mkdir "$DIR_PACOTES_DEB"
wget -c "$URL_GOOGLE_CHROME"       -P "$DIR_PACOTES_DEB"
wget -c "$URL_DISCORD"             -P "$DIR_PACOTES_DEB"
wget -c "$URL_ZOOM"                -P "$DIR_PACOTES_DEB"
wget -c "$URL_MYSQL_WORKBENCH_UBUNTU_2204" -P "$DIR_PACOTES_DEB"
wget -c "$URL_ZSHRC_FILE"          -P "$DIR_DOWNLOADS"

## Instalando pacotes .deb baixados na sessão anterior ##
sudo dpkg -i $DIR_PACOTES_DEB/*.deb

## Adicionando chave pública e repositório Docker ##
sudo apt install curl gnome-keyring -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose # Baixa o docker-compose

## Instalando pacotes no apt
for nome_do_pacote in ${PACOTES_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_pacote; then # Só instala se já não estiver instalado
    apt install "$nome_do_pacote" -y
  else
    echo "[INSTALADO] - $nome_do_pacote"
  fi
done

## Finalizando configuração Docker ##
sudo usermod -aG docker $USER # Adiciona user ao grupo docker
sudo chmod +x /usr/local/bin/docker-compose # Instala o docker-compose

## Instalando pacotes Snap ##
sudo snap install slack --classic

## Instalando NVM e Node ##
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts

## Instalando Oh! My zsh e definindo como terminal padrão ##
 yes | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
 mv /$DIR_DOWNLOADS/.zshrc $HOME/.zshrc # Substitui o arquivo .zshrc com o nvm configurado

# ---------------------------------------------------------------------- #

# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #
## Finalização, atualização e limpeza##
sudo apt update && sudo apt dist-upgrade -y
sudo apt autoclean
sudo apt autoremove -y
rm -rf $DIR_PACOTES_DEB
newgrp docker # Ativa as alterações feitas no Docker
# ---------------------------------------------------------------------- #