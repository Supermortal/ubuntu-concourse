sudo service docker stop
sudo mv /var/lib/docker $1
sudo ln -s $1 /var/lib/docker