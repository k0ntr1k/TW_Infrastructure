FROM openjdk:latest

WORKDIR /app

ADD front-end.jar front-end.jar

ENV APP_PORT=8080
ENV STATIC_URL=http://static-service:8000
ENV QUOTE_SERVICE_URL=http://quotes-service:8080
ENV NEWSFEED_SERVICE_URL=http://newsfeed-service:8080
ENV NEWSFEED_SERVICE_TOKEN=

EXPOSE 8080

CMD java -jar front-end.jar