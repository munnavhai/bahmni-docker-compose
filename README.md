# bahmni-docker-compose

## On the Bahmni server

Create the target directory in `/opt`:
```
sudo mkdir -p /opt/bahmni
```

Give permissions to the required users:
```
sudo setfacl -m "u:<username>:rwX" /opt/bahmni
sudo setfacl -m "d:u:<username>:rwX" /opt/bahmni
```

Clone this repo:
```
git clone https://github.com/MSF-OCB/bahmni-docker-compose/ /opt/bahmni
```

If you have trouble login in, you can also copy your (passphrase protected!!) ssh key to the server, add it to your github account and clone via ssh:
```
git clone git@github.com:MSF-OCB/bahmni-docker-compose.git /opt/bahmni/
```

And copy over the config file and edit it:
```
cp .env.template .env
vim .env
```

## On the development machine

From the development machine (nixos-dev in Ixelles) we set up a reverse tunnel to access the Docker registry:
```
ssh -N -R 5000:localhost:5000 maadi-emr-a
```

## On the Bahmni server

Pull the image, bring up the container and watch the logs:
```
docker-compose down
docker-compose pull
docker-compose up -d
docker-compose logs -f
```

