FROM openjdk:latest

WORKDIR /app

ADD front-end.jar front-end.jar

ENV APP_PORT=8080
ENV STATIC_URL=http://localhost:8000
ENV QUOTE_SERVICE_URL=http://localhost:8081
ENV NEWSFEED_SERVICE_URL=http://localhost:8082
ENV NEWSFEED_SERVICE_TOKEN=T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX

EXPOSE 8080:8088

CMD java -jar front-end.jar