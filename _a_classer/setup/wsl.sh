# WSL

Run disitribution: ``wsl -d <distribution>``

## Config

``\\wsl$\$DISTRO\etc\wsl.conf``
``~/.wslconfig``

## Initialize

### Create user

```bash
NEW_USER='jeanmgirard'

# if already exists: sudo usermod -a -G sudo -s /bin/bash "$NEW_USER"
useradd -m -G sudo -s /bin/bash "$NEW_USER"
passwd "$NEW_USER"

tee /etc/wsl.conf <<_EOF
[user]
default=${NEW_USER}
_EOF


```

### Cloud-init

```bash
cat cloud.cfg | sudo tee /etc/cloud/cloud.cfg


cloud-init clean
cloud-init -d -f ./cloud.cfg init
cloud-init -d -f ./cloud.cfg modules --mode final
```

### SSH Keys

```bash
mkdir -p ~/.ssh ~/.kube ~/.azure ~/.aws

cp -r /mnt/c/users/JeanM/.ssh/* ~/.ssh/
cp -r /mnt/c/users/JeanM/.kube/* ~/.kube/
cp -r /mnt/c/users/JeanM/.azure/* ~/.azure/
cp -r /mnt/c/users/JeanM/.aws/* ~/.aws/
```
