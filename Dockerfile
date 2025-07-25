# ARM64 플랫폼 명시
FROM --platform=linux/arm64 oven/bun:alpine AS base

# 작업 디렉토리 설정
WORKDIR /app

# 필요한 시스템 패키지 설치 (Git 등)
RUN apk add --no-cache git

# 의존성 설치를 위한 stage
FROM base AS deps
COPY package.json bun.lock* bunfig.toml ./
RUN bun install --frozen-lockfile

# 개발용 stage
FROM base AS dev
COPY --from=deps /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["bun", "run", "dev"]

# 빌드 stage
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 라우트 생성 및 빌드
RUN bun run prebuild
RUN bun run build

# 프로덕션 stage
FROM base AS production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/src ./src
COPY --from=build /app/package.json ./
COPY --from=build /app/tsconfig.json ./

# 프로덕션 포트
EXPOSE 3000

# 프로덕션 실행
CMD ["bun", "run", "start"]