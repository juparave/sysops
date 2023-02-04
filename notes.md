## New Ubutnu 22.04 setup

### Basic tools

    # apt install fzf net-tools ripgrep golang


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



