# ovsoi's blog


## Start

```bash
git clone -b source --single-branch https://github.com/ovsoil/ovsoil.github.io.git blog
cd blog
git submodule update --init

# new blog
./new.sh new-post

# local server: http://localhost:1313/
hugo server

# deploy
./deploy.sh
```
