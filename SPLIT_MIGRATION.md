# 📋 Project Split Summary

This document outlines the separation of the Dashboard and API code into independent projects.

## 📁 New Structure

```
openwhatsapp/                    # API Server (NestJS)
├── src/                        # Backend source code
├── test/                       # Backend tests
├── Dockerfile                  # API Docker image
├── package.json               # API dependencies
└── ...

openwhatsapp-dashboard/        # Dashboard (React/Vite) 
├── src/                       # Frontend source code
├── public/                    # Static assets
├── Dockerfile                 # Dashboard Docker image
├── nginx.conf                 # Nginx configuration
├── package.json              # Dashboard dependencies
└── ...
```

## 🚀 Development

### API Server (openwhatsapp)
```bash
cd openwhatsapp
npm install
npm run start:dev   # Development server
npm run build       # Production build
npm start           # Run production build
```

### Dashboard (openwhatsapp-dashboard)
```bash
cd openwhatsapp-dashboard
npm install
npm run dev         # Development server with hot reload
npm run build       # Production build
npm run preview     # Preview production build
```

## 🐳 Docker

### API Container
```bash
cd openwhatsapp
docker build -t openwa-api .
docker run -p 3000:3000 openwa-api
```

### Dashboard Container
```bash
cd openwhatsapp-dashboard
docker build -t openwa-dashboard .
docker run -p 80:80 openwa-dashboard
```

### Docker Compose (Running Both)
Create a `docker-compose.yml` at the parent level:

```yaml
version: '3.8'

services:
  api:
    build: ./openwhatsapp
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - ./data:/app/data

  dashboard:
    build: ./openwhatsapp-dashboard
    ports:
      - "80:80"
    depends_on:
      - api
```

Then run:
```bash
docker-compose up
```

## 📦 Dependencies

- **API**: NestJS, TypeORM, Socket.io, PostgreSQL, Redis, Bull
- **Dashboard**: React 19+, Vite, React Router, TanStack Query, Lucide Icons

## 🔄 Git Repositories

You can now manage these as:
1. **Single monorepo**: Keep both in same Git repo with separate subfolders
2. **Separate repos**: Push each to its own Git repository for independent management

## 💡 Environment Variables

### API (.env)
```
DATABASE_URL=postgres://user:password@localhost/openwa
REDIS_URL=redis://localhost:6379
NODE_ENV=development
PORT=3000
```

### Dashboard (.env)
```
VITE_API_URL=http://localhost:3000
```

## 🔗 Communication

The dashboard communicates with the API via:
- REST API endpoints (port 3000)
- WebSocket connections for real-time updates (Socket.io)

Configure the API URL in the dashboard environment or through the UI settings.

## ✅ Migration Complete

The code split is complete. The dashboard and API are now independent projects that can be:
- Developed separately
- Deployed independently
- Scaled individually
- Maintained with separate schedules
