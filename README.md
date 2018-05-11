docker build -t fitbazaar-dev:latest .

or build without using cache:
docker build --no-cache=true -t fitbazaar-dev:latest .

docker run -it -h dev.fitbazaar.com --name DEV --restart=always \
           -p 8021:22 \
           -p 8081:80 \
           -p 8441:443 \
           -p 8301:3306 \
           -p 8011:9000 \
           -p 8001:9001 \
           fitbazaar-dev


# Run app via Docker

### 1. Install docker
https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac

### 2. Run the app
docker volume create --name=cs-volume

cd coinshares-web/
npm install
docker-compose up

### 3 View the website
When running docker, the browser URI => http://localhost  (Note: THERE IS NO PORT NUMBER when you run docker!)


`******** RESTARTING SERVER - DOCKER VERSION ***********

/coinshares-web$ => docker-compose restart
/coinshares-web$ => docker-compose up




## Local machine installation (without Docker)

Special Git Setup Note: Setup git so that it "git ignores" the lib/db/init.js file 
=> local machine version has contactPoints: ['127.0.0.1']}) while production has contactPoints 'cassandra' so git ignore this file

### Install NodeJS
https://nodejs.org/en/download/
http://blog.teamtreehouse.com/install-node-js-npm-mac

### Install JDK8
Install 8 because 9 is not compatible with current Cassandra

Download: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

vi ~/.bashrc 
Add:
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

java -version

### Install Maven

### Install Cassandra
mkdir -p ~/opt/packages/cassandra/
cd ~/opt/packages/cassandra/
curl -O http://mirror.cc.columbia.edu/pub/software/apache/cassandra/3.11.2/apache-cassandra-3.11.2-bin.tar.gz
tar xzvf apache-cassandra-3.11.2-bin.tar.gz
ln -s ~/opt/packages/cassandra/apache-cassandra-3.11.2 ~/opt/cassandra

vi ~/.bashrc 
if [ -d "$HOME/opt/cassandra" ]; then
    export PATH="$PATH:$HOME/opt/cassandra/bin"
fi

source ~/.bashrc
cassandra -v

### Start Cassandra and install schema
cassandra -f

in separate window:
~/opt/cassandra/bin/cqlsh

install schema from services/README.md - run statements from sections
Install Schema
Populate Schema

### Install Node dependencies
cd <path>/web
npm install

### Uncomment ./lib/db/init.js
const cassandraClient = new cassandra.Client({ contactPoints: ['127.0.0.1']});

### Run the node app
npm start
NOTE: Run this multiple times, due to schema creation delay issue (run it, get error, kill it, run it again, get error, kill it, etc.)

When running docker, to view website in browser: URI => `http://localhost`  (Note: there is no port number when you run docker!)

### View the website
When running locally (not using docker), the browser URI => `http://localhost:3000` (Note: You MUST INCLUDE the port number 3000)

## Restart

-kill node.js process => `ctl + c`
-start cassandra: /coinshares-web$ => `cassandra -f`
-start node.js server: /coinshares-web$ => `npm start`

## Build

mvn clean install
docker build --tag=cs-services:latest .

The –tag option will give the image its name and –rm=true will remove intermediate images after it has been built successfully

## Run

     --volume=spring-cloud-config-repo:/var/lib/spring-cloud/config-repo \

    docker run --name=cs-services --publish=8080:8080 cs-services:latest
          
## Debugging

### NodeJS
1. Run the app in debug mode

    DEBUG=express:* nodemon --inspect bin/www
    
NOTE: Run this before doing npm start

NOTE: Run this multiple times, due to schema creation delay issue (run it, get error, kill it, run it again, get error, kill it, etc.)

2. Open chrome debug tools

    chrome://inspect/#devices -> "Open dedicated DevTools for Node"

### Services
IntelliJ Free edition:
1) Select menu Run -> Edit Configurations... -> "+" -> Select "Remote" -> Name it smth like "Spring Remote"
2) Run 

    mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
    
3) Connect to your app by running your Remote Configuration created prviously on step 2. 

Test POST:

    curl -i -X POST -H 'Content-Type: application/json' -d '{"id": "100000000001", "activators_id": "vadia"}' http://localhost:8080/giftcard/activate
    curl -i -X POST -H 'Content-Type: application/json' -d '{"id":"514971ad-4927-4af7-93a1-9f30041e677d","recipientsId":"3a776c87-1cd6-42d0-95ca-5c25f6d17721","recipientsEmail":"ustymenko+2@gmail.com","recipientsPubAddr":"tb1qspdpgl2a657xsya7srt3f7klle0h6l2e459pkj","recipientNew":true,"sendersId":null,"coinId":"BTC","amount":"0.1","txHEX":null,"sentDate":null,"sendersUserAgent":null,"sendersIp":null,"exchangeRateUSD":"8220.590000","minersFee":"0.00000255"}' http://localhost:8080/tx/notify

# PROD Deployment
Login to production server: 

    ssh root@165.227.4.2

## First time deployment

Install bitcoinj

    git clone https://github.com/bitcoinj/bitcoinj.git
    cd bitcoinj
    mvn clean install -Dmaven.test.skip=true

Download code to production
    
    cd ~
    git clone ...

Create DB container and install schema

    docker-compose up cs-db
    Ctrl+Z
    docker exec -it cs-db cqlsh
    -> paste commands from services/schema.cql

Build services

    cd ~/coinshares-web/services && mvn clean install -Dmaven.test.skip=true

Build and run new containers: 

    cd ~/coinshares-web && docker-compose up --build

## Subsequent deployment
    
Update code
    
    cd ~/coinshares-web
    git pull origin

Update schema, if there are any updates

    docker exec -it cs-db cqlsh
    -> paste commands to update schema

Stop and remove web and services containers
    
    docker stop cs-web cs-services && docker rm cs-web cs-services && docker rmi cs-web cs-services

Build services

    cd ~/coinshares-web/services && mvn clean install -Dmaven.test.skip=true        
 
Build and run new containers: 

    cd ~/coinshares-web && docker-compose up --build

## DEV tips
### JS
https://stackoverflow.com/questions/2559318/how-to-check-for-an-undefined-or-null-variable-in-javascript
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/throw

### Handlebars
https://stackoverflow.com/questions/10736907/handlebars-js-else-if

### Misc

dependency tree:

    mvn dependency:tree

### Troubleshooting
If you get smth like: 

    ERROR: Get https://registry-1.docker.io/v2/library/cassandra/manifests/3.11: unauthorized: incorrect username or password

Do:

    docker logout

### Docker cheat sheet
List volumes:

    docker volume ls

To start exited container:

    docker start -a -i container_id

Start image with different command/entrypoint:

    docker run -ti --entrypoint=sh cs-services:latest

To detach the tty without exiting the shell, use the escape sequence 

    Ctrl+p + Ctrl+q.

List running containers:

    docker ps

List all containers:

    docker ps -a

Stop container:

    docker stop container_id

Remove container:

    docker rm container_id

List all images:
    
    docker images

Remove image:

    docker rmi image_id

Run bash inside container:

    docker exec -it container_id bash

Run top:

    docker top container_id

Inspect full container config:

    docker inspect container_id

One liner to stop / remove all of Docker containers:

    docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)

One liner to delete all images:

    docker rmi $(docker images)

List all orphaned volumes with

    docker volume ls -qf dangling=true
    
Eliminate all of them with

    docker volume rm $(docker volume ls -qf dangling=true)
    
    docker volume ls 
    docker volume inspect cs-volume
    
Follow container logs

     docker logs --follow cs-services
     

