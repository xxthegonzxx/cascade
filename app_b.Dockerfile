FROM ubuntu:latest
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential sqlite3 libsqlite3-dev

COPY ./app_b.py ./requirements.txt ./schema.sql /app/

WORKDIR /app

RUN pip install --user -r requirements.txt
RUN sqlite3 database.db < schema.sql

EXPOSE 5001
HEALTHCHECK CMD wget -O- http://localhost:5001/ || exit 1

ENTRYPOINT ["python"]
CMD ["app_b.py"]