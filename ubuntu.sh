# Start with new goodies
sudo apt update -y
sudo apt upgrade -y

# Set up ZSH
sudo apt install zsh wget git -y
chsh -s /usr/bin/zsh $(whoami)
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
source ~/.zshrc

# Set the shell
sed -ie "s/ZSH_THEME\=\"robbyrussell\"/ZSH_THEME\=\"cloud\"/g" ~/.zshrc

# # #
