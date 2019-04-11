FROM ubuntu:latest as builder

RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential

COPY ./app_a.py ./requirements.txt /app/
WORKDIR /app

RUN pip install --user -r requirements.txt

EXPOSE 5000
HEALTHCHECK CMD wget -O- http://localhost:5000/ || exit 1

ENTRYPOINT ["python"]
CMD ["app_a.py"]