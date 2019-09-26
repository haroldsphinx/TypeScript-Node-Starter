FROM node:10.14.2

MAINTAINER <adedayoakinpelu@gmail.com>

WORKDIR /app

ADD . /app

RUN npm install 

RUN npm rebuild node-sass && npm run build

EXPOSE 3000

CMD ["npm", "start"]