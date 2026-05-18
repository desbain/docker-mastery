# ── Stage 1: Build React app ──────────────────────────────────
FROM node:20-alpine AS builder

LABEL stage="builder"

WORKDIR /build

# Copy package files first for layer caching
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install --silent

# Copy source and build
COPY public/ ./public/
COPY src/    ./src/

# Build optimised production bundle
RUN npm run build

# ── Stage 2: Serve with Nginx ─────────────────────────────────
FROM nginx:1.25-alpine AS final

LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL org.opencontainers.image.title="taskflow-frontend"

# Copy built React files into nginx html directory
COPY --from=builder /build/build /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Create non-root nginx user
RUN addgroup -S nginxgroup && adduser -S -G nginxgroup nginxuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
