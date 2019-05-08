FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-setuptools

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

COPY . /opt/app

ENV PYTHONIOENCODING utf-8
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV FLASK_ENV development
ENV FLASK_APP aeon.py

EXPOSE 80

WORKDIR /opt/app

RUN ["chmod", "+x", "/opt/app/run_devserver.sh"]