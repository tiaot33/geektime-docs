FROM python:3.11-slim AS mkdocs-builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY . ./

RUN pip install -r requirements.txt  -i https://pypi.tuna.tsinghua.edu.cn/simple

RUN python mkdocs.py

RUN mkdocs build

FROM node:22-slim AS pagefind-builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY pagefind.yml ./

COPY --from=mkdocs-builder /app/site ./site

RUN npm run pagefind

FROM python:3.11-slim  AS production

WORKDIR /app

RUN pip install fastapi uvicorn requests  -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY --from=pagefind-builder /app/site ./site
ADD  app.py .

EXPOSE 8091

CMD python app.py
