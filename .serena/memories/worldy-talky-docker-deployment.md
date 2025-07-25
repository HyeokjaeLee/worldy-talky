# Worldy Talky Docker 배포 설정

## Overview
Bun 기반 React 프로젝트를 ARM64 EC2에 GitHub Container Registry를 통해 자동 배포하는 시스템 구축

## 핵심 설정 파일

### Dockerfile (Multi-stage Build)
- Base: `oven/bun:alpine`
- 개발/프로덕션 분리된 스테이지
- ARM64 플랫폼 지원
- `--platform` 플래그는 빌드 시에 지정 (Dockerfile에서 하드코딩 X)

### GitHub Actions (.github/workflows/deploy.yml)
- 트리거: `release/20250726` 브랜치 push
- GitHub Container Registry 사용 (`ghcr.io`)
- 빌드 → 푸시 → EC2 배포 파이프라인
- `if: success()` 조건으로 실패 시 배포 방지

### Docker Compose
- 개발용: `docker-compose up dev` (hot reload)
- 프로덕션용: `docker-compose up app`

## 주요 이슈 해결

### GitHub Container Registry 권한 문제
**에러:** `denied: installation not allowed to Create organization package`
**해결:** GitHub 레포 Settings → Actions → General → Workflow permissions를 "Read and write permissions"로 변경

### 태그 소문자 문제  
**에러:** `repository name must be lowercase`
**해결:** 환경변수로 하드코딩 `hyeokjaelee/worldy-talky`

### Docker 플랫폼 워닝
**워닝:** `FromPlatformFlagConstDisallowed`
**해결:** Dockerfile에서 `--platform=linux/arm64` 제거, GitHub Actions에서만 지정

## 필요한 GitHub Secrets
- `EC2_HOST`: EC2 인스턴스 IP
- `EC2_USER`: SSH 사용자명 (ubuntu/ec2-user)  
- `EC2_SSH_KEY`: PEM 키 전체 내용
- `GITHUB_TOKEN`: 자동 제공 (추가 설정 불필요)

## EC2 요구사항
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

## 보안 고려사항
- GitHub Container Registry는 Private
- 환경변수는 런타임에 주입 (빌드 타임 X)
- EC2 Security Group에서 3000번 포트만 열기

## 배포 프로세스
1. 코드 push → GitHub Actions 자동 트리거
2. Bun 기반 Docker 이미지 빌드 (ARM64)
3. GitHub Container Registry에 푸시
4. EC2에 SSH 접속하여 이미지 pull & 실행
5. 포트 3000에서 서비스 제공

## 성능 최적화
- Docker Hub 대신 GitHub Container Registry 사용으로 보안성 향상
- Multi-stage build로 이미지 크기 최적화
- EC2에서 직접 빌드하지 않고 이미지만 pull하여 배포 속도 향상