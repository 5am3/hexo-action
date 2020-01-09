#!/bin/sh

set -e

git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

npm install

sh -c "hexo $INPUT_CMD"

echo ::set-output name=notify::"$INPUT_CMD complate."