ssh-keygen

type $env:USERPROFILE\.ssh\id_rsa.pub | ssh root@rp-f07d64 "cat >> .ssh/authorized_keys"

type $env:USERPROFILE\.ssh\id_rsa.pub | ssh root@169.254.57.89 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

type C:\Users\photonecho\.ssh\id_rsa.pub | ssh root@169.254.57.89 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

