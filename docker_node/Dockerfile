FROM node:8.11.3

MAINTAINER FLLab

RUN mkdir /FLLab

COPY . /FLLab

WORKDIR /FLLab/org

#Run npm i npm@latest -g

#RUN npm install

RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

RUN cnpm install

EXPOSE 4000


