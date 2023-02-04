## New Ubutnu 22.04 setup

### Basic tools

    # apt install fzf net-tools ripgrep golang build-essential silversearcher-ag tmux zip unzip


### SSH

* Permission denied (publickey).
`/etc/ssh/sshd_config`
```
PasswordAuthentication yes
PermitEmptyPasswords no

KbdInteractiveAuthentication yes
```

### inputrc

vim `/etc/skel/.inputrc`
```
"\e[1~": beginning-of-line
"\e[2~": yank
"\e[3~": delete-char
"\e[4~": end-of-line
"\e[5~": history-search-backward
"\e[6~": history-search-forward
$if term=xterm
"\e[2;5~": yank
"\e[3;5~": delete-char
"\e[5;5~": history-search-backward
"\e[6;5~": history-search-forward
$endif
```

Copy `.inputrc` to $HOME/

### Docker

ref: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04

Install a few prerequisite packages which let apt use packages over HTTPS:

    # apt install apt-transport-https ca-certificates curl software-properties-common

Then add the GPG key for the official Docker repository to your system:

    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

Add the Docker repository to APT sources:

    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
Update your existing list of packages again for the addition to be recognized:

    # apt update

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

    # apt-cache policy docker-ce

You’ll see output like this, although the version number for Docker may be different:

```
Output of apt-cache policy docker-ce
docker-ce:
  Installed: (none)
  Candidate: 5:20.10.14~3-0~ubuntu-jammy
  Version table:
     5:20.10.14~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
     5:20.10.13~3-0~ubuntu-jammy 500
        500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
```

Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu 22.04 (jammy).

Finally, install Docker:

    # apt install docker-ce

Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it’s running:

    # systemctl status docker

Adding user to docker group, change user with _your_ username

    # usermod -aG docker ${USER}

Install `docker-compose` plugin, for user

    $ mkdir -p ~/.docker/cli-plugins/
    $ curl -SL https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    $ chmod +x ~/.docker/cli-plugins/docker-compose

### nginx

    # apt install nginx

