# =============================================================================
# OpenWA - Render Production Dockerfile
# Optimized for Render + Puppeteer + WhatsApp Sessions
# =============================================================================

# ===== Stage 1: Build =====
FROM node:22-slim AS builder

WORKDIR /app

# Build environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source
COPY . .

# Build app
RUN npm run build

# =============================================================================
# ===== Stage 2: Production =====
# =============================================================================

FROM node:22-slim AS production

WORKDIR /app

# Production environment
ENV NODE_ENV=production
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# =============================================================================
# Install Chromium + Required Libraries
# =============================================================================

RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    dumb-init \
    ca-certificates \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Puppeteer Configuration
# =============================================================================

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# =============================================================================
# Copy Package Files
# =============================================================================

COPY package*.json ./

# Install Production Dependencies Only
RUN npm ci --omit=dev && npm cache clean --force

# =============================================================================
# Copy Built App
# =============================================================================

COPY --from=builder --chown=node:node /app/dist ./dist

# =============================================================================
# Create Persistent Data Directories
# =============================================================================

RUN mkdir -p \
    /app/data/sessions \
    /app/data/media \
    /app/data/plugins

# Ensure the non-root node user can read/write persisted runtime data
RUN chown -R node:node /app/data /app/dist
USER node

# =============================================================================
# Render Uses PORT Environment Variable
# =============================================================================

ENV PORT=10000

# =============================================================================
# Expose Internal Port
# =============================================================================

EXPOSE 10000

# =============================================================================
# Health Check
# =============================================================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 10000) + '/api/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# =============================================================================
# Start Application
# =============================================================================

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "dist/main"]

