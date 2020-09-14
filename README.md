# A containerized drone-server with nolimits

![](https://github.com/nemonik/drone/workflows/Building%20and%20Pushed/badge.svg)

This project builds and pushes [nemonik/drone](https://hub.docker.com/r/nemonik/drone), a containerized Enterprise Edition drone-server built with nolimits, to Docker Hub.

## Why?

The [drone/drone]( https://hub.docker.com/r/drone/drone) container image you pull from Docker Hub is the Enterprise Edition and without a license is free for a trial period of 5000 builds after which you will need to obtain a license via their [website](https://drone.io/enterprise). 

As per <https://docs.drone.io/enterprise/#what-is-the-difference-between-open-source-and-enterprise>, the Drone Enterprise Edition is free for organizations with under $1 million US dollars in annual gross revenue and less than $5 million in debt or equity funding.

You can build the Enterprise Edition as well as the severely limited Open Source Edition -- The two can be compared [here](https://docs.drone.io/enterprise/#what-is-the-difference-between-open-source-and-enterprise). -- from source using the build tags described [here](https://docs.drone.io/enterprise/#how-do-i-use-the-enterprise-edition-for-free). 

This project builds and containerized the Enterprise Edition with nolimits so you can use it for free, if you or your organization falls within the requirements of the [license](https://github.com/drone/drone/blob/master/LICENSE).

## License

Be careful using this container image as you must meet the obligations and conditions of the [license](https://github.com/drone/drone/blob/master/LICENSE) as not doing so will be subject you or your organization to penalty under US Federal and International copyright law.

A copy of the Drone Enterprise Edition license can be found [here](https://github.com/drone/drone/blob/master/LICENSE).

The code for [the project](https://github.com/nemonik/drone) that builds the [nemonik/drone](https://hub.docker.com/r/nemonik/drone) image and pushes it to Docker Hub is distributed under the [BSD 3-Clause "New" or "Revised" License](https://github.com/nemonik/drone/blob/master/LICENSE).

Please, don't confuse the two licenses.

## How do I use the nemonik/drone container image?

Here's an example docker-compose.yml file using this container image integrated with self-hosted GitLab.

```
version: "2"

# Copyright (C) 2020 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <mjwalsh@nemonik.com>

services:
    drone-postgresql:
        image:
            sameersbn/postgresql:10-2
        restart: always
        environment:
            - DB_NAME=drone
            - DB_USER=drone
            - DB_PASS=password
            - DB_EXTENSION=pg_trgm
        ports:
            - "5432"
        volumes:
            - ./volumes/drone-postgresql/var/lib/postgresql:/var/lib/postgresql:Z

    drone-runner-docker:
        image:
           drone/drone-runner-docker:1.4.0
        restart: always
        environment:
           - DRONE_RPC_PROTOCOL=http
           - DRONE_RPC_HOST=192.168.0.10
           - DRONE_RPC_SECRET=shared_secret
           - DRONE_RUNNER_CAPACITY=1
           - DRONE_DEBUG_PRETTY=true
           - DRONE_LOGS_DEBUG=true
        ulimits:
           nofile:
              soft: "262144"
              hard: "262144" 
        ports:
            - "3000"
        volumes:
           - /var/run/docker.sock:/var/run/docker.sock
        depends_on:
           - drone-server

    drone-server:
        image:
            nemonik/drone:latest
        restart: always
        environment:
            - DRONE_DATABASE_DRIVER=postgres
            - DRONE_DATABASE_DATASOURCE=postgres://drone:password@drone-postgresql:5432/drone?sslmode=disable
            - DRONE_GIT_ALWAYS_AUTH=false
            - DRONE_GITLAB_SERVER=http://192.168.0.202:80
            - DRONE_GITLAB_CLIENT_ID=<FROM GITLAB>
            - DRONE_GITLAB_CLIENT_SECRET=<FROM GITLAB>
            - DRONE_RPC_SECRET=shared_secret
            - DRONE_SERVER_HOST=192.168.0.10
            - DRONE_SERVER_PROTO=http
            - DRONE_AGENTS_ENABLED=true
            - DRONE_TLS_AUTOCERT=false
            - DRONE_LOGS_PRETTY=true
            - DRONE_LOGS_COLOR=true
            - DRONE_USER_CREATE=username:root,admin:true
        ulimits:
          nofile:
            soft: "262144"
            hard: "262144"
        ports:
            - 80:80
        depends_on:
            - drone-postgresql
```

You will need to modify the above following Drone's [GitLab integration documentation](https://docs.drone.io/server/provider/gitlab/).

Then provided you have docker and docker-compose installed, spin up Drone

```
docker-compose up -d
```

To scale to 10 runners simply enter into the cli

```
docker-compose up -d --scale drone-runner-docker=10
```

## See also

I've written a number of an Ansible roles to spin up what you need

- [Common role](https://github.com/nemonik/common-role) to configure the instance past the base CentOS 7, Alpine 3.10 or Ubuntu Bionic image
- [Docker role](https://github.com/nemonik/docker-role) to install and configure Docker
- [Docker-compose role](https://github.com/nemonik/docker-compose-role) to install Docker-compose
- [Drone role](https://github.com/nemonik/drone-role) to install Drone

These roles were authored to support my [Hands-on DevOps course](https://github.com/nemonik/hands-on-DevOps).
