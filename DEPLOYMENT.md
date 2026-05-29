# OpenWA API - Deployment & Setup Guide

This is the API server for OpenWA WhatsApp Gateway.

## 🚀 Local Development

### Prerequisites
- Node.js 20+
- PostgreSQL 12+
- Redis 6+

### Installation

```bash
npm install
```

### Environment Variables

Create `.env` file:

```env
DATABASE_URL=postgres://user:password@localhost:5432/openwa
REDIS_URL=redis://localhost:6379
NODE_ENV=development
PORT=3000
```

### Running

```bash
# Development with watch mode
npm run start:dev

# Production build
npm run build
npm start

# Debug mode
npm run start:debug
```

API will be available at `http://localhost:3000`

## 📝 Database Migrations

```bash
# Generate new migration
npm run migration:generate -- -n MigrationName

# Run pending migrations
npm run migration:run

# Show migration status
npm run migration:show

# Revert last migration
npm run migration:revert
```

## 🧪 Testing

```bash
# Unit tests
npm run test

# Watch mode
npm run test:watch

# Coverage report
npm run test:cov

# E2E tests
npm run test:e2e
```

## 🐳 Docker

### Build Image

```bash
docker build -t openwa-api:latest .
```

### Run Container

```bash
docker run -d \
  --name openwa-api \
  -p 3000:3000 \
  -e DATABASE_URL="postgres://user:password@postgres:5432/openwa" \
  -e REDIS_URL="redis://redis:6379" \
  -v $(pwd)/data:/app/data \
  openwa-api:latest
```

## 📚 API Documentation

- Swagger API Docs: `http://localhost:3000/api/docs`
- API Specification: See `/docs/06-api-specification.md`

## 🔐 Security

- Use environment variables for sensitive data
- Enable HTTPS in production
- Configure CORS appropriately
- Use strong database passwords
- Enable rate limiting

## 🆘 Troubleshooting

**Connection Issues**
```bash
# Test database connection
npm run typeorm -- query "SELECT 1"

# Check migration status
npm run migration:show
```

**Port Already in Use**
```bash
# Use different port
PORT=3001 npm run start:dev
```

## 📦 Related Projects

- **Dashboard**: See `../openwhatsapp-dashboard/`
- **Documentation**: See `/docs/`

## 📄 License

MIT - See LICENSE file
