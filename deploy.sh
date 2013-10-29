#!/bin/sh

SERVER_IP=96.126.112.59
APPLICATION_NAME=`pwd | awk -F"/" '{print $NF}'`

cat <<EOF
####################################################################################################
#                                         cap deploy:setup                                         #
####################################################################################################
EOF

cap deploy:setup



while [ "$DB_PWD_CONFIRM" != "Y" -a "$DB_PWD_CONFIRM" != "y" ]; do
  cat <<EOF
####################################################################################################
#                                   Type Down Database Password:                                   #
####################################################################################################
EOF
  read DATABASE_PASSWORD

  cat <<EOF
####################################################################################################
#                 Your Database Password: $DATABASE_PASSWORD, ARE YOUR SURE? (Y|N)
####################################################################################################
EOF
  read DB_PWD_CONFIRM
done



cat <<EOF
####################################################################################################
#             server: /home/deployer/apps/$APPLICATION_NAME/shared/config/database.yml
####################################################################################################
EOF

cat <<EOF | ssh deployer@$SERVER_IP "cat > /home/deployer/apps/$APPLICATION_NAME/shared/config/database.yml"
production:
  adapter: postgresql
  encoding: unicode
  database: ${APPLICATION_NAME}_production
  pool: 25
  username: $APPLICATION_NAME
  password: $DATABASE_PASSWORD

EOF



cat <<EOF 
####################################################################################################
#                              DATABASE USER: $APPLICATION_NAME
#                              DATABASE NAME: ${APPLICATION_NAME}_production
####################################################################################################
EOF

ssh -t deployer@$SERVER_IP "
sudo -u postgres psql <<EOF
create user $APPLICATION_NAME with password '$DATABASE_PASSWORD';
create database ${APPLICATION_NAME}_production owner $APPLICATION_NAME;
EOF
"



cat <<EOF
####################################################################################################
#                                         cap deploy:cold                                          #
####################################################################################################
EOF

cap deploy:cold



cat <<EOF
####################################################################################################
#                                       server restart nginx                                       #
####################################################################################################
EOF

ssh -t deployer@$SERVER_IP "
if [ -f /etc/nginx/sites-enabled/default ]; then
  sudo rm -rf /etc/nginx/sites-enabled/default
  sudo service nginx restart
fi
"



cat <<EOF
####################################################################################################
#                                  prepare elasticsearch and nodes                                 #
####################################################################################################
EOF

ssh deployer@$SERVER_IP "
cd /home/deployer/apps/$APPLICATION_NAME/current
RAILS_ENV=production bundle exec rake environment tire:import CLASS='Post' FORCE=true
RAILS_ENV=production bundle exec rake db:nodes
"



cat <<EOF
####################################################################################################
#                                           ENJOY!  ^-^                                            #
####################################################################################################
EOF
