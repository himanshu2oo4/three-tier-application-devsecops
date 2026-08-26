# =========================
# Stage 1: Build Client
# =========================

FROM node:20-alpine AS client-builder

WORKDIR /usr/src/app/client

COPY client/package*.json ./

RUN npm ci

COPY client/ ./

RUN npm run build


# =========================
# Stage 2: Production Server
# =========================

FROM node:20-alpine AS production

WORKDIR /usr/src/app/server

COPY server/package*.json ./

RUN npm ci --omit=dev

COPY server/ ./

# Copy the built frontend from Stage 1
RUN mkdir -p ./public

COPY --from=client-builder \
    /usr/src/app/client/build \
    ./public


# Production environment
ENV NODE_ENV=production


# Create non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup


# Give ownership
RUN chown -R appuser:appgroup /usr/src/app


# Switch to non-root user
USER appuser


EXPOSE 5000


CMD ["npm", "start"]
