#NGINX

sudo apt-get -y update
sudo apt-get install -y nginx
sudo cp concourse.conf /etc/nginx/sites-available/concourse.conf
sudo ln -s /etc/nginx/sites-available/concourse.conf /etc/nginx/sites-enabled/concourse.conf
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart

#DOCKER:

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update
sudo apt-get -y install docker-ce
sudo apt -y install docker-compose

#CONCOURSE:

sudo docker rm --force $(sudo docker ps -aq)
./generate-keys.sh
sudo docker-compose up -d

#FLY:

echo "Waiting on Concourse server"
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://127.0.0.1:80/api/v1/cli?arch=amd64&platform=linux)" != "400" ]]; do sleep 1; printf "%c" "."; done'
curl "http://127.0.0.1:80/api/v1/cli?arch=amd64&platform=linux" --output fly

sudo mkdir -p /usr/local/bin
sudo cp fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly

fly -t main login -c http://127.0.0.1:80 -u "$CONCOURSE_MAIN_TEAM_LOCAL_USER" -p "$CONCOURSE_LOCAL_USER_PASSWORD"