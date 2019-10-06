# BattleSnake Microservice

BattleSnake microservice built on Docker/Python/Flask/Nginx/Gunicorn.

Copyright © 2017 Beanstream Internet Commerce, Inc.

MIT Licensed - Use and abuse as you wish.

This project requires Python 3.

Note that as one, of many, considerations to scaling your web app that you should review the use of WEB_CONCURRENCY and
Gunicorn. WEB_CONCURRENCY can be set to 3 for the Test/QA environment in order to set the number of Worker processes
that Gunicorn will use to process requests. Test/QA usually can use a t2.small instance with 1 CPU core. # of Worker
process was set using a formula of '(2 x $num_cores) + 1'.

<http://docs.gunicorn.org/en/stable/settings.html#workers>

```bash
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/9.5/bin"
export WEB_CONCURRENCY=3
```

## BattleSnake 2017

This repo is where our Bounty Snake lives, hunts and slithers. Of course our snake is of the python variety. Should you
be unlucky enough to have crossed paths with a Blacktail then you are already aware of the venomous fangs, evil eyes
and forked tongue that await you.

More info on BattleSnake can be found here:

- <https://github.com/sendwithus/battlesnake-python>
- <https://stembolthq.github.io/battle_snake/>
- <https://en.wikipedia.org/wiki/Python_(genus)>

## Persistence

If you would like to persist the data between game turns logging to redis can be turned on in the `settings.conf` file.
Redis must be running on localhost. The easiest way to do this is to run the docker container.

`docker run -d -p 6379:6379 redis`

## Logging

Logging is accomplished via standard Python logging. If running under Docker you will find logs under /var/logs/nginx/
and /var/logs/supervisor/. If running a Dockerized container under AWS Elastic Beanstalk with the template
Dockerrun.aws.json deployment configuration you will find logs under the host system under /var/logs/containers/ and you
will also be able to download these logs based on volume mounts in the Elastic Beanstalk Webapp Console in AWS.

## App Setup & Installation

- Execute a git clone command on this repo and in a terminal cd into the root project directory.

```bash
git clone https://github.com/Beanstream/blacktail.git
cd blacktail/app
```

- Install virtualenv

```bash
[sudo] pip install virtualenv
```

- Create and/or Activate project environment

```bash
virtualenv -p python3 venv
source venv/bin/activate
```

- Install/update project dependencies

```bash
$ pip install -r requirements.txt
```

## Execution

- To run the flask app just for development only (not for production) just do
  this:

```bash
python server.py
```

## Build & Deploy

- Sample build and deploy commands:

```bash
$ sudo pip install awscli --ignore-installed six
$ aws ecr get-login --region us-west-2
$ aws configure
AWS Access Key ID [None]: {id}
AWS Secret Access Key [None]: {secret}
Default region name [None]:     us-west-2
Default output format [None]:
$ aws ecr get-login --region us-west-2
$ docker login -u AWS -p {key} -e none {repo}
$ cd blacktail/
$ docker build -t beanstream/blacktail:latest .
$ docker tag beanstream/blacktail:latest {repo}/beanstream/blacktail:0.0.1
$ docker push {repo}/beanstream/blacktail:0.0.1
```

- Or... Sample build and deploy commands with make:

```bash
make build
```

- To run a docker image locally for additional dev/testing:

```bash
docker run -d -p 80:8080 beanstream/blacktail:0.0.1
```
