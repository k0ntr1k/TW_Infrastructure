FROM openjdk:latest

WORKDIR /app

ADD front-end.jar front-end.jar

ENV APP_PORT=8080

EXPOSE 8080

CMD java -jar front-end.jar