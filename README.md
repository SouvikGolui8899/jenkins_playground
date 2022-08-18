## README

### Overview

This is a tool to build a running docker container of Jenkins.

Note: Please copy the ssh.qe.tar file into root location of this project's directory

### Execution (manually)

To bring up the docker containers run the following command:

```
sudo docker-compose up -d
```

To bring down docker conatiners run the following command:

```
sudo docker-compose down
```


### Execution (with [bootstrap.sh](bin/bootstrap.sh))

To Bring up Jenkins in Docker:

```
./bin/bootstrap.sh --setup
```

To Teardown Jenkins in Docker:

```
./bin/bootstrap.sh --teardown
```

To delete mounted volumes:

```
./bin/bootstrap.sh --remove-volumes
```
