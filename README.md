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
    ├── .database/
    │   ├── mariadb/
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
    │   │   │   └── Dockerfile-prod
    │   │   │   └── nginx.conf
    │   │   │   └── nginx-service.sh
    │   ├── node/
    │   │   └── Dockerfile
    │   │   └── Dockerfile-prod
    │   │   └── start-service.sh
    │   ├── php/
    │   │   └── 8.2/
    │   │   │   └── Dockerfile
    │   │   │   └── Dockerfile-prod
    │   │   │   └── start-service.sh
    │   │   │   └── supervisord.conf
    │   │   └── logrotate/
    │   │   │   └── laravel-worker_log.conf
    │   │   │   └── supervisor_log.conf
    │   │   └── xdebug.ini
    │   ├── redis/
    │   │   └── redis.conf
    ├── .logs/
    │   ├── backend/
    │   ├── letsencrypt/
    │   ├── mariadb/
    │   ├── nginx/
    │   ├── frontend/
    │   └── supervisor/
    ├── backend/
    ├── frontend/
    └── .env
    └── .gitignore
    └── docker-compose.yml
    └── docker-compose.prod.yml
    └── README.md

## 개발용과 배포용 설정을 확인하고 실행 시켜야 한다.
* 설정은 .env 파일에서 관리하며 .env.prod 파일로 실 서비스 설정을 한다.
* xdebug는 IDE나 editor에서 추가 설정해줘야 하며 serverName은 기본 docker-php로 설정되어 있다. 
  (변경해서 사용하세요.)
* backend/ 디렉토리에 Laravel 프로젝트를 설치합니다.
* frontend/ 디렉토리에 Nuxt.js 프로젝트를 설치합니다.
```shell
# 개발환경은 아래와 같이 실행하여 시작합니다.
docker-compose up --build --force-recreate

# 프로덕션 배포 시에는 아래와 같이 실행하여 프로덕션 설정을 적용하여 실행합니다.
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build --force-recreate

# docker cache 로 문제가 발생될 수 있으므로 아래와 같이 실행하여 캐시로 인한 문제를 회피하며 빌드
docker builder prune -af
docker-compose build --no-cache
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

## Backend / Frontend 모든 소스 설치가 완료 되었다면 다시 실행
```shell
docker compose down
docker compose up --build --force-recreate
```

## Xdebug 사용 시 설정
### vscode
vscode 사용시 .vscode/launch.json 에 추가
1. 왼쪽 사이드바에서 "Run and Debug" 아이콘을 클릭합니다.
2. "Listen for Xdebug" 설정을 선택합니다.
3. "Start Debugging" 버튼을 클릭하거나 F5를 누릅니다.
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/backend": "${workspaceFolder}/backend"
            }
        }
    ]
}
```

### IntelliJ
A. PHP 인터프리터 설정:
1. File > Settings (Windows/Linux) 또는 IntelliJ IDEA > Preferences (macOS)로 이동
2. Languages & Frameworks > PHP로 이동
3. CLI Interpreter 옆의 '...' 버튼 클릭
4. '+' 버튼을 클릭하고 'From Docker, Vagrant, VM, Remote...' 선택
5. 'Docker Compose' 선택 후 서비스에서 'php' 선택
6. 'OK' 클릭하여 설정 저장

B. 서버 구성:
1. File > Settings (Windows/Linux) 또는 IntelliJ IDEA > Preferences (macOS)로 이동
2. Languages & Frameworks > PHP > Servers로 이동
3. '+' 버튼을 클릭하여 새 서버 추가
4. 이름을 'Docker-php'로 설정 (PHP_IDE_CONFIG의 serverName과 일치해야 함)
5. Host를 'localhost'로 설정
6. 'Use path mappings' 체크박스 선택
7. 프로젝트 루트 디렉토리를 '/var/www/html'에 매핑

C. Run/Debug 구성:
1. Run > Edit Configurations 메뉴 선택
2. '+' 버튼 클릭 후 'PHP Remote Debug' 선택
3. 이름 설정 (예: 'Docker PHP Debug')
4. 서버를 앞서 생성한 'Docker-php'로 선택
5. IDE key를 'INTELLIJ'로 설정 (xdebug.ini의 idekey와 일치)


#### IntelliJ IDEA에서 디버깅을 시작하려면:
1. 설정한 'Docker Debug' 구성을 선택합니다.
2. 'Debug' 버튼을 클릭하거나 Shift+F9를 누릅니다.
3. 코드에 중단점을 설정하고 애플리케이션을 실행합니다.

