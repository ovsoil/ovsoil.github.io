#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

if [ ! -d public ]; then
  git clone -b master --single-branch https://github.com/ovsoil/ovsoil.github.io.git public
fi

# build the project
hugo -t even

cd public
git add .

msg="update site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git commit -m "$msg"
# push source to github
git push origin master

cd ..
