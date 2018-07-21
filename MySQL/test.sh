#!/bin/bash

docker run -d -p 5209:3306 2b

sleep 60

mysql -h127.0.0.1 -P5209 -uJim -p123456
