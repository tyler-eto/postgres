# Postgres Docker Container
* fully sets up database for writing and accessing
* takes dataset.txt as an input which it grabs from github

### Tip: get rid of all docker images and containers:
* docker rm $(docker ps -a -q)
* docker rmi $(docker images -q)
* docker start <id>
* docker attach <id>
* detach without stopping ctrl+p+q

* use ENTRYPOINT so kubernetes yaml can overwrite it with "command"