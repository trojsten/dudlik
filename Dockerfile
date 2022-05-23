FROM node:17-bullseye-slim as tailwind
WORKDIR /app
RUN npm install -g pnpm@~6.31.0
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY tailwind.config.js .
COPY dudlik ./dudlik
RUN pnpm run build
CMD ["pnpm", "run", "dev"]

FROM python:3.10-slim-bullseye
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends tini && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHONFAULTHANDLER 1
ENV PYTHONUNBUFFERED 1

RUN pip install --no-cache-dir pipenv

# create virtualenv
RUN python3 -m venv /venv
ENV PATH /venv/bin:$PATH
ENV VIRTUAL_ENV=/venv

COPY Pipfile* ./
RUN pipenv install --deploy

COPY manage.py entrypoint.sh ./
COPY dudlik/ ./dudlik
#COPY --from=tailwind /app/dudlik/static/app.css /app/dudlik/static/app.css

RUN useradd --create-home app
USER app

ENTRYPOINT []
CMD ["/app/entrypoint.sh"]
