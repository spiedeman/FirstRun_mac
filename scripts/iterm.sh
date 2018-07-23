#!/bin/bash

cd $ROOTDIR/config/iterm2
for file in `ls .`
do
    cp $file ~/.$file
done

[ ! -f "$HOME/.bash_profile" ] && touch $HOME/.bash_profile

echo "#!/bin/bash" > ~/.bash_profile
echo "if [ -f ~/.bashrc ]; then" >> ~/.bash_profile
echo "    source ~/.bashrc" >> ~/.bash_profile
echo "fi" >> ~/.bash_profile
