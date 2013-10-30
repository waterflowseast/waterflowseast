This is the source code of [WaterFlowsEast.com](http://waterflowseast.com).

# RUN ON LOCAL

* make sure you have installed imagemagick.
* make sure you have kept postgres, elasticsearch, redis-server running.

## modify Postgres config file

Postgres's default max_connections is too small, we have to change it to 100.  
if you installed postgres via homebrew, config file is at /usr/local/var/postgres/postgresql.conf.
max_connections value is at about line 64.

On Mac, shared memory is too small, we need to increase it.
you can run `sysctl -a | grep "kern.sysv.shm"` to see the current values.

modify /etc/sysctl.conf. if it doesn't exist, create it.

```
kern.sysv.shmmax=1610612736
kern.sysv.shmmin=1
kern.sysv.shmmni=256
kern.sysv.shmseg=64
kern.sysv.shmall=393216
```

then you have to reboot to make this config file work



## install smart_chinese plugin for elasticsearch

you can visit this [github repo](https://github.com/elasticsearch/elasticsearch-analysis-smartcn)
to see how to install it based on your elasticsearch version. when installed, restart your elasticsearch.



## run on your local machine

``` sh
git clone http://github.com/waterflowseast/waterflowseast.git
cd waterflowseast
bundle install

# create database
createuser waterflowseast
createdb waterflowseast_development -O waterflowseast
createdb waterflowseast_test -O waterflowseast

cp config/database.example.yml config/database.yml
cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb

rake db:schema:load
rake environment tire:import CLASS=Post FORCE=true
rake db:nodes
```

run `rails s` and you can go have fun.

if you want to have some sample users, you can run `rake db:sample_users`,
this will give you 30 regular users (foobar1 ~ foobar30) and 1 admin user (admin), all with password 'foobar'.

if you want to have some sample data (create sample users first), this is what you do:

* open another terminal to run `bundle exec sidekiq`
* in your current terminal, run `rake db:sample_data`

and if you don't want to miss the sidekiq realtime graphics, you can sign in as admin,
and input `localhost:3000/sidekiq` in your browser's address bar, then run the commands above.
the progress is about 7 minutes.

the generated sample data has some sequence problems, for example:

* all the direct comments are floor 1
* received messages are out of order



# RUN ON SERVER

## create a deployer user

on your VPS, as user root, create a deployer user: `adduser deployer --ingroup sudo`



## upload server_setup.sh to your deployer@YOUR-VPS

below is server_setup.sh, and it is only tested in Ubuntu 12.04 64bit

``` sh
#!/bin/sh

cat <<EOF
####################################################################################################
#                                     ~/.ssh/authorized_keys                                       #
####################################################################################################
EOF

mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys



while [ ! -s ~/.ssh/authorized_keys ]; do
  cat <<EOF
####################################################################################################
#                           COPY LOCAL MACHINE'S PUBLIC KEY TO SERVER                              #
#                       change YOUR_VPS_ADDRESS to your actual vps address                         #
#                                                                                                  #
#      cat ~/.ssh/id_rsa.pub | ssh deployer@YOUR_VPS_ADDRESS 'cat >> ~/.ssh/authorized_keys'       #
####################################################################################################
EOF
  read
done



cat <<EOF
####################################################################################################
#                                           install gawk                                           #
####################################################################################################
EOF

sudo apt-get -y update
sudo apt-get -y install gawk



cat <<EOF
####################################################################################################
#                                       /etc/ssh/sshd_config                                       #
####################################################################################################
EOF

cat /etc/ssh/sshd_config | awk '
/PermitRootLogin (yes|no) *$/ { print "PermitRootLogin no"; next }
/PasswordAuthentication (yes|no) *$/ { print "PasswordAuthentication no"; next }
{ print }
' | sudo tee /etc/ssh/sshd_config.tmp

sudo mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config



cat <<EOF
####################################################################################################
#                                       restart ssh daemon                                         #
####################################################################################################
EOF

sudo service ssh restart



cat <<EOF
####################################################################################################
#                                      install basic packages                                      #
####################################################################################################
EOF

sudo apt-get -y install build-essential git-core curl python-software-properties



cat <<EOF
####################################################################################################
#                                       install dependencies                                       #
####################################################################################################
EOF

sudo apt-get -y install \
autoconf automake autotools-dev binutils bison cpp cpp-4.6 g++ g++-4.6 gawk \
gcc gcc-4.6 libbison-dev libc-dev-bin libc6-dev libffi-dev libgdbm-dev \
libgomp1 libmpc2 libmpfr4 libncurses5-dev libquadmath0 libreadline6-dev \
libsigsegv2 libsqlite3-dev libssl-dev libstdc++6-4.6-dev libtinfo-dev \
libtool libxml2-dev libxslt1-dev libxslt1.1 libyaml-0-2 libyaml-dev \
linux-libc-dev m4 make pkg-config sqlite3 zlib1g-dev



cat <<EOF
####################################################################################################
#                                            install rvm                                           #
####################################################################################################
EOF

\curl -L https://get.rvm.io | bash -s stable



cat <<EOF
####################################################################################################
#                              load rvm script and check requirements                              #
####################################################################################################
EOF

source ~/.rvm/scripts/rvm
rvm requirements



cat <<EOF
####################################################################################################
#                                          install ruby                                            #
####################################################################################################
EOF

rvm install 1.9.3



cat <<EOF
####################################################################################################
#                                 skip rdoc and ri when install gems                               #
####################################################################################################
EOF

echo "gem: --no-rdoc --no-ri" > ~/.gemrc



cat <<EOF
####################################################################################################
#                                          install rails                                           #
####################################################################################################
EOF

gem install rails -v 3.2.13



cat <<EOF
####################################################################################################
#                                        install postgresql                                        #
####################################################################################################
EOF

sudo add-apt-repository ppa:pitti/postgresql
sudo apt-get -y update
sudo apt-get -y install postgresql libpq-dev



cat <<EOF
####################################################################################################
#                            modify /etc/postgresql/9.1/main/pg_hba.conf                           #
####################################################################################################
EOF

sudo cat /etc/postgresql/9.1/main/pg_hba.conf | awk '
/^local +all +all +\w+$/ { sub(/\w+$/, "md5"); print; next }
{ print }
' > /tmp/pg_hba.conf

cat /tmp/pg_hba.conf | sudo tee /etc/postgresql/9.1/main/pg_hba.conf



cat <<EOF
####################################################################################################
#                                        restart postgresql                                        #
####################################################################################################
EOF

sudo service postgresql restart



cat <<EOF
####################################################################################################
#                                          install nginx                                           #
####################################################################################################
EOF

sudo add-apt-repository ppa:nginx/stable
sudo apt-get -y update
sudo apt-get -y install nginx



cat <<EOF
####################################################################################################
#                                           start nginx                                            #
####################################################################################################
EOF

sudo service nginx start



cat <<EOF
####################################################################################################
#                                           install mail                                           #
####################################################################################################
EOF

sudo apt-get -y install telnet postfix



cat <<EOF
####################################################################################################
#                                         install node.js                                          #
####################################################################################################
EOF

sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get -y update
sudo apt-get -y install nodejs



cat <<EOF
####################################################################################################
#                                           install jre                                            #
####################################################################################################
EOF

sudo apt-get install openjdk-7-jre-headless -y



cat <<EOF
####################################################################################################
#                                      install elasticsearch                                       #
####################################################################################################
EOF

wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb
sudo dpkg -i elasticsearch-0.90.3.deb
rm -f elasticsearch-0.90.3.deb



cat <<EOF
####################################################################################################
#                         install smart chinese analysis for elasticsearch                         #
####################################################################################################
EOF

sudo /usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-smartcn/1.6.0
sudo service elasticsearch restart



cat <<EOF
####################################################################################################
#                                        install ImageMagick                                       #
####################################################################################################
EOF

sudo apt-get install imagemagick



cat <<EOF
####################################################################################################
#                                           install redis                                          #
####################################################################################################
EOF

sudo apt-get install redis-server
```

after uploaded, ssh to deployer@YOUR-VPS, and run `source server_setup.sh`.



## preparation

* make sure each example file is copied to generate a formal one
* make sure everything related to GitHub account and VPS is changed to reflect yours
* make sure your GitHub repo is ready



## deploy

in your application root directory, just run `source deploy.sh`.
