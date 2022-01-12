#!/bin/sh

set -e

# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

# install hexo env
npm install hexo-cli -g
npm install hexo-deployer-git --save


# setup secret config
echo "in->$INPUT_ELSE_CONFIG" >> ./source/test1
CHANGYAN_APPID=`echo "$INPUT_ELSE_CONFIG" | awk -F 'CHANGYAN_APPID:' '{print $2}' | awk -F ';' '{print $1}'`
CHANGYAN_CONF=`echo "$INPUT_ELSE_CONFIG" | awk -F 'CHANGYAN_CONF:' '{print $2}' | awk -F ';' '{print $1}'`
VALINE_APPID=`echo "$INPUT_ELSE_CONFIG" | awk -F 'VALINE_APPID:' '{print $2}' | awk -F ';' '{print $1}'`
VALINE_APPKEY=`echo "$INPUT_ELSE_CONFIG" | awk -F 'VALINE_APPKEY:' '{print $2}' | awk -F ';' '{print $1}'`
GITMENT_CLIENT_ID=`echo "$INPUT_ELSE_CONFIG" | awk -F 'GITMENT_CLIENT_ID:' '{print $2}' | awk -F ';' '{print $1}'`
GITMENT_CLIENT_SECRET=`echo "$INPUT_ELSE_CONFIG" | awk -F 'GITMENT_CLIENT_SECRET:' '{print $2}' | awk -F ';' '{print $1}'`

sed -i "s/CHANGYAN_APPID/$CHANGYAN_APPID/g" ./themes/black-blue-master/_config.yml
sed -i "s/CHANGYAN_CONF/$CHANGYAN_CONF/g" ./themes/black-blue-master/_config.yml
sed -i "s/VALINE_APPID/$VALINE_APPID/g" ./themes/black-blue-master/_config.yml
sed -i "s/VALINE_APPKEY/$VALINE_APPKEY/g" ./themes/black-blue-master/_config.yml
sed -i "s/GITMENT_CLIENT_ID/$GITMENT_CLIENT_ID/g" ./themes/black-blue-master/_config.yml
sed -i "s/GITMENT_CLIENT_SECRET/$GITMENT_CLIENT_SECRET/g" ./themes/black-blue-master/_config.yml
echo "in2->$GITMENT_CLIENT_SECRET"  >> ./source/test1

# deployment
if [ "$INPUT_COMMIT_MSG" = "none" ]
then
    hexo g -d
elif [ "$INPUT_COMMIT_MSG" = "" ] || [ "$INPUT_COMMIT_MSG" = "default" ]
then
    # pull original publish repo
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g -d
else
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g -d -m "$INPUT_COMMIT_MSG"
fi

echo ::set-output name=notify::"Deploy complate."
