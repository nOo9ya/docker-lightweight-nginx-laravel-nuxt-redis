# docker-lightweight laravel + nuxt
docker(alpine) = nginx + php-fpm + mariadb + redis + node

# …or repository from the command line
```shell
git clone https://github.com/nOo9ya/docker-lightweight-nginx-laravel-nuxt-redis.git

# or

git init
git remote add origin https://github.com/nOo9ya/docker-lightweight-nginx-laravel-nuxt-redis.git
git branch -M main
git push -u origin main

# or

git init --initial-branch=main
git remote add origin https://github.com/nOo9ya/docker-lightweight-nginx-laravel-nuxt-redis.git
git pull origin main
```


## 디렉토리 구조

docker 파일과 volume으로 연결할 docker, database, logs로 각각 폴더로 구분하여 volume 마운트 시킴

* 폴더 성격 별로 상위 디렉터리를 구성하고, 각 컨테이너 기능별로 하위 폴더를 구성.

디렉토리 구조는 다음과 같습니다.

    .
    project-root/
    ├── .certbot/
    │   ├── conf/
    │   ├── www/
    ├── .databases/
    │   ├── mariadb/
    │   └── postgresql/
    │   └── redis/
    ├── .docker/
    │   ├── nginx/
    │   │   └── web/
    │   │   │   └── logrotate/
    │   │   │   │   └── nginx_log.conf
    │   │   │   └── sites/
    │   │   │   │   └── default.conf
    │   │   │   │   └── dev.default.conf
    │   │   │   └── ssl/
    │   │   │   │   └── default.crt
    │   │   │   │   └── default.csr
    │   │   │   │   └── default.key
    │   │   │   └── Dockerfile
    │   │   │   └── Dockerfile-dev
    │   │   │   └── nginx.conf
    │   │   │   └── nginx-service.sh
    │   ├── nuxt/
    │   │   └── Dockerfile
    │   │   └── Dockerfile-dev
    │   │   └── start-service.sh
    │   ├── php/
    │   │   └── web/
    │   │   │   └── Dockerfile
    │   │   │   └── Dockerfile-dev
    │   │   │   └── start-service.sh
    │   │   │   └── supervisord.conf
    │   │   └── logrotate/
    │   │   │   └── laravel-worker_log.conf
    │   │   │   └── supervisor_log.conf
    │   ├── redis/
    │   │   └── redis.conf
    ├── .logs/
    │   ├── laravel/
    │   ├── letsencrypt/
    │   ├── mariadb/
    │   ├── nginx/
    │   ├── nuxt/
    │   └── postgresql/
    │   └── supervisor/
    ├── laravel/
    ├── nuxt/
    └── .env
    └── .gitignore
    └── docker-compose.yml
    └── README.md

## 개발용과 배포용 설정을 확인하고 실행 시켜야 한다.
* 설정은 .env 파일에서 관리하며 Dockerfile, Dockerfile-dev을 선택, 나머진 접근 사용자와 비밀번호 설정, 포트 설정을 확인 후 실행한다.
* xdebug는 IDE나 editor에서 추가 설정해줘야 하며 serverName은 기본 docker-php로 설정되어 있다. 
  (변경해서 사용하세요.)
```shell
# LIVE Server settings example
#APP_ENV=production
#DOCKER_FILE=Dockerfile
#XDEBUG_MODE=off

# DEVELOP settings example
APP_ENV=local
DOCKER_FILE=Dockerfile-dev
PHP_IDE_CONFIG=serverName=docker-php
XDEBUG_MODE=debug
```
* nginx는 nginx/web/Dockerfile 수정하여 사용
* 사용하는 용도에 맞추어 주석을 변경하고 conf 파일을 설정 확인 후 사용
```shell
# live server conf
#ADD ./.docker/nginx/web/sites/default.conf /etc/nginx/conf.d/default.conf

# dev server conf
ADD ./.docker/nginx/web/sites/dev.default.conf /etc/nginx/conf.d/default.conf

```

## Frontend nuxt 파일이 없을 시 접근 후 설치
```shell
docker exec -it nuxt-js /bin/sh
# nuxt js install 진행 
# ex)
npx nuxi@latest init .
```

## Backend Laravel 파일이 없을 시 접근 후 설치
```shell
docker exec -it php /bin/sh
# laravel install 진행
# ex) 원하는 버전으로 설치
composer create-project laravel/laravel .(프로젝트명 .은 현재 경로에 그냥 설치) --prefer-dist 
"9.*"
# ex2) php 버전에 맞추어 최신 버전으로 설치
composer create-project laravel/laravel .
```

## Backend / Frontend 모든 소스가 있다면 다시 실행
```shell
docker compose down
docker compose up --build --force-recreate
```