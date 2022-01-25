FROM python

WORKDIR /app

ADD public/css css/
ADD public/serve.py serve.py

EXPOSE 8000

CMD python3 ./serve.py