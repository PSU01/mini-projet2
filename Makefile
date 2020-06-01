IMAGE = psunday/fake-backend:travis-ci

network:
	docker network create  fbk_network
volume:
	docker volume create mysql_data

image:
	docker build -t $(IMAGE) .

run:
#	docker run -d --name=fake-backend -p 80:80 $(IMAGE)
	docker run --name dbpsu -d -v mysql_data:/var/lib/mysql -p 3306:3306 -e  MYSQL_ROOT_PASSWORD=rootpwdpsu -e  MYSQL_DATABASE=battleboat -e MYSQL_USER=battleuser -e  MYSQL_PASSWORD=battlepass --network fbk_network  mysql:5.7
	
	sleep 30s

	docker run --name fakebackend -d -v ${PWD}/fake-backend:/etc/backend/static -p 80:3000 -e  DATABASE_HOST=dbpsu -e  DATABASE_PORT=3306 -e  DATABASE_USER=battleuser -e DATABASE_PASSWORD=battlepass -e DATABASE_NAME=battleboat  --network fbk_network  $(IMAGE)
 
	# start all containers which are in the exited state.
	#docker start $(docker ps -a -q --filter "status=exited")
	sudo docker start  fakebackend
	
	# to let the container start after run test
	sleep 5
	# list all the create images 
	docker images 
	
	# list all the create container
	docker ps -a 

test:

	if [ "$$(curl -X GET http://localhost:80/health)" = "ok" ]; then echo "test OK => status:200"; exit 0; else echo "test KO status:500"; exit 1; fi

clean:
	docker rm -vf  fake-backend

push-image:
	docker push $(IMAGE)


.PHONY: image run test clean push-image
