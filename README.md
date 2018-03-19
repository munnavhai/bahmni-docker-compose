# bahmni-docker-compose

From the development machine we set up a reverse tunnel:
```
ssh -R 5000:localhost:5000 maadi-emr-a
```

```
docker-compose up -d
docker-compose logs -f
```
