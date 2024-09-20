FROM node:alpine

LABEL authors="Lei"

WORKDIR /app

# 安装pnpm
RUN npm install -g pnpm

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 使用 pnpm 安装依赖
RUN pnpm install

# 定义构建时的变量
ARG DATABASE_URL
ARG DATABASE_SCHEMA

# 将构建时的变量设置为环境变量
ENV DATABASE_URL=${DATABASE_URL}
ENV DATABASE_SCHEMA=${DATABASE_SCHEMA}

RUN echo $DATABASE_URL

# 使用 QEMU 运行 Prisma 命令
RUN qemu-arm-static -D /usr/bin/npx prisma generate
RUN qemu-arm-static -D /usr/bin/npx prisma migrate deploy

RUN npm run build

# Set NuxtJS system variables
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

WORKDIR /app

EXPOSE 3000

CMD [ "npm", "run", "start" ]
