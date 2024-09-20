FROM alpine:latest

LABEL authors="Lei"

# 安装基础工具和依赖
RUN apk add --no-cache \
    curl \
    binutils \
    libstdc++

# 设置工作目录
WORKDIR /app

# 下载并安装Node.js for armv7
RUN arch=armv7l && \
    version=$(curl -sL https://nodejs.org/dist/latest/ | grep -oP 'node-v\d+\.\d+\.\d+\.linux-' | head -1) && \
    curl -sL https://nodejs.org/dist/latest/${version}${arch}.tar.xz | tar -xJf - --strip-components=1 -C /usr/local

# 清理下载的二进制文件
RUN apk del curl binutils

# 确保Node.js和npm命令在PATH中
ENV PATH="/usr/local/bin:$PATH"

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
ENV DATABASE_URL=$DATABASE_URL
ENV DATABASE_SCHEMA=$DATABASE_SCHEMA

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

CMD ["npm", "run", "start"]
