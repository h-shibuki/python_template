FROM python:3.8-slim-buster
WORKDIR /usr/src/app
RUN useradd -d /usr/src/app -U python
RUN chown python:python /usr/src/app
RUN apt-get update && apt-get install -y \
  build-essential \
  && rm -rf /var/lib/apt/lists/*
USER python
COPY --chown=python:python requirements.lock ./
RUN pip install --upgrade pip && pip install -r requirements.lock

FROM python:3.8-slim-buster
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/bin/tini", "--"]
WORKDIR /usr/src/app
RUN useradd -d /usr/src/app -U python
RUN chown python:python /usr/src/app
EXPOSE 80
USER python
COPY --from=0 /usr/src/app ./
COPY src src
COPY tests tests

CMD ["/usr/src/app/.local/bin/uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "80"]