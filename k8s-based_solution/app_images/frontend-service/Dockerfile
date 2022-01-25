FROM openjdk:latest

WORKDIR /app

ADD front-end.jar front-end.jar

ENV APP_PORT=8080
ENV STATIC_URL=http://static-assets:8000
ENV QUOTE_SERVICE_URL=http://quotes_service:8080
ENV NEWSFEED_SERVICE_URL=http://newsfeed_service:8080
ENV NEWSFEED_SERVICE_TOKEN=dummy

EXPOSE 8080

CMD java -jar front-end.jar