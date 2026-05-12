
# SSH Key generation:

## Mac

Check for existing SSH keys: `ls -la ~/.ssh`

If you already see files like:

`id_ed25519, id_ed25519.pub`

or

`id_rsa, id_rsa.pub`

then you already have SSH keys.

Create .ssh folder if needed: `mkdir -p ~/.ssh && chmod 700 ~/.ssh`

Generate a new SSH key:

`ssh-keygen -o -a 100 -t ed25519 -C "your_email@domain.com" -f ~/.ssh/id_ed25519`

Show your public key: `cat ~/.ssh/id_ed25519.pub`

## Windows:

Check for existing SSH keys: `dir $HOME\.ssh`

If you see files like:

`id_ed25519, id_ed25519.pub`

or

`id_rsa, id_rsa.pub`

then you already have SSH keys.

Create .ssh folder if needed: `mkdir $HOME\.ssh`

Generate a new SSH key:
`ssh-keygen -o -a 100 -t ed25519 -C "your_email@domain.com" -f $HOME\.ssh\id_ed25519`

Show your public key: `type $HOME\.ssh\id_ed25519.pub`