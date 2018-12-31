# Instructions

## Create User And Assign Sudo

* First run `sudo adduser concourse`
* Add a password when prompted
* Then run `sudo usermod -aG sudo concourse`
* Finally run `su - concourse` to switch to the new user

## Add Environment Variables To /etc/environment

* Check .env.sample for variables that need to be set
  * It can help to have a .env file with your variables in it
  * This file is already ignored by the .gitignore
* Run `sudo vi /etc/environment` or `sudo nano /etc/environment` (or use the text editor of your choice)
* Copy your variables from your .env file (or manually edit them) into the environment file

## Clone This Repository

* Make sure you're in the "~" directory (or whatever directory you want to keep the files)
  * `cd ~` to get to the directory
* Run `git clone https://github.com/Supermortal/ubuntu-concourse.git`
* Run `cd ubuntu-concourse`

## Run init.sh

* Run `. ./init.sh` (the extra dot is to preserve the $PRIVATE_KEY variable)
* This command should add all the dependecies your need, including the fly CLI
* Your Concourse instance should now be available at your desired host at port 80