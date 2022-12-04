#!/bin/bash

## EDITED BY------------------------------------------
## Esteban Arias - Bits4BeesCostaRica -
## ---------------------------------------------------


rand-str()
{
    # Return random alpha-numeric string of given LENGTH
    #
    # Usage: VALUE=$(rand-str $LENGTH)
    #    or: VALUE=$(rand-str)

    local DEFAULT_LENGTH=64
    local LENGTH=${1:-$DEFAULT_LENGTH}

    LC_CTYPE=C  tr -dc A-Za-z0-9 </dev/urandom | head -c $LENGTH
    # -dc: delete complementary set == delete all except given set
}


clear
msg="
                                           WORKPRESS                                               
"


tput setaf 128;
printf "$msg"
tput setaf 7;

printf "\n\n\nNecesitaremos algo de información para instalar este sistema\n\n"

read -p "Presiona enter para continuar..."

## ______________________________
## TIME ZONE
printf "\n\n⏳ Necesitamos configurar la zona horaria\n"
while [[ -z "$TZ" ]]
do
  read -p "   System Time Zone $(tput setaf 128)(UTC)$(tput setaf 7): "  TZ
  TZ=${TZ:-UTC}
  echo "      Selected Time Zone ► ${TZ} ✅"
done

#MYSQL_ROOT_PASSWORD
random_str=$(rand-str 20)
printf "\n\n🔐 Necesitamos crear una clave segura para el ROOT de Mysql Db\n"
while [[ -z "$MYSQL_ROOT_PASSWORD" ]]
do
  read -p "   MYSQL Root Password $(tput setaf 128)(${random_str})$(tput setaf 7): "  MYSQL_ROOT_PASSWORD
  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-${random_str}}
  echo "      Selected MYSQL Root Password ► ${MYSQL_ROOT_PASSWORD} ✅"
done

#MYSQL_PASSWORD
random_str=$(rand-str 20)
printf "\n\n Necesitamos crear una clave segura de Mysql Db\n"
while [[ -z "$MYSQL_PASSWORD" ]]
do
  read -p "   MYSQL Password $(tput setaf 128)(${random_str})$(tput setaf 7): "  MYSQL_PASSWORD
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-${random_str}}
  echo "      Selected MYSQL Root Password ► ${MYSQL_PASSWORD} ✅"
done

##############################
#MYSQL_DATABASE = "wordpress_db"
MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress_db}
#TZ=${TZ:-UTC}
#MYSQL_USER = "wordpress_user"
MYSQL_USER=${MYSQL_USER:-wordpress_user}
##############################

msg="
          RESUMEN                                                                                                                           
"

tput setaf 128;
printf "$msg"
tput setaf 7;

printf "\n\n\n"
printf "   🟢 TIMEZONE: $(tput setaf 128)${TZ}$(tput setaf 7)\n"
printf "   🟢 MYSQL ROOT PASS: $(tput setaf 128)${MYSQL_ROOT_PASSWORD}$(tput setaf 7)\n"
printf "   🟢 MYSQL DATABASE: $(tput setaf 128)${MYSQL_DATABASE}$(tput setaf 7)\n"
printf "   🟢 MYSQL USER: $(tput setaf 128)${MYSQL_USER}$(tput setaf 7)\n"
printf "   🟢 MYSQL PASS: $(tput setaf 128)${MYSQL_PASSWORD}$(tput setaf 7)\n"

printf "\n\n\n\n";
read -p "Presiona Enter para comenzar la instalación..."
sleep 2


sudo yum update -y
sudo yum install git python3 pip3 -y
sudo yum search docker
sudo yum install docker -y

# sudo usermod -a -G docker ec2-user
id ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service

#sudo pip3 install docker-compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose 

sudo usermod -a -G docker ec2-user

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo git clone https://github.com/Bits4bees/Workpress.git

cd /home/ec2-user/Workpress

## ______________________________
## INSALL INIT
filename='.env'


#SERVICES .ENV
sudo sh -c " echo 'environment=prod' >> $filename"
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# TIMEZONE (all containers).' >> $filename"
sudo sh -c " echo 'TZ=${TZ}' >> $filename"
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# M Y S Q L ' >> $filename"
sudo sh -c " echo 'MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}' >> $filename"
sudo sh -c " echo 'MYSQL_DATABASE=${MYSQL_DATABASE}' >> $filename"
sudo sh -c " echo 'MYSQL_USER=${MYSQL_USER}' >> $filename"
sudo sh -c " echo 'MYSQL_PASSWORD=${MYSQL_PASSWORD}' >> $filename"

sudo docker-compose -f docker-compose.yml up -d