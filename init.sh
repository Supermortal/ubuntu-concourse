sudo apt-get -y update

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    jq

sudo add-apt-repository -y ppa:certbot/certbot
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


sudo apt-get -y update

#SSH KEY

while [ "$1" != "" ]; do
    case $1 in
        -gk | --generate-key )
            yes | ssh-keygen -b 4096 -f id_rsa -t rsa -N ''
            ;;
    esac
    shift
done

export PRIVATE_KEY=`cat /home/concourse/ubuntu-concourse/id_rsa`

#CERTBOT

sudo apt-get install -y python-certbot-nginx

#NGINX

sudo apt-get install -y nginx
sudo cp concourse /etc/nginx/sites-available/concourse
sudo ln -s /etc/nginx/sites-available/concourse /etc/nginx/sites-enabled/concourse
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart

#DOCKER:

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo apt-get -y install docker-ce
sudo apt-get -y install docker-compose

#CONCOURSE:

while [ "$1" != "" ]; do
    case $1 in
        -cc | --clear-containers )
            sudo docker rm -v --force $(sudo docker ps -aq)
            sudo docker rmi $(sudo docker images -q)
            ./cleanup-docker.sh
            ;;
    esac
    shift
done
./generate-keys.sh
sudo docker-compose up -d

#FLY:

echo "Waiting on Concourse server"
bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://127.0.0.1:80/api/v1/cli?arch=amd64&platform=linux)" != "400" ]]; do sleep 1; printf "%c" "."; done'
wget -O fly "http://127.0.0.1:80/api/v1/cli?arch=amd64&platform=linux"

sudo mkdir -p /usr/local/bin
sudo cp fly /usr/local/bin
sudo chmod 0755 /usr/local/bin/fly

fly -t main login -c http://127.0.0.1:80 -u "$CONCOURSE_MAIN_TEAM_LOCAL_USER" -p "$CONCOURSE_LOCAL_USER_PASSWORD"