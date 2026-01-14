# ---------- Build stage ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Installer runtime libs pour Prisma
RUN apk add --no-cache libc6-compat openssl

# Copier package.json + package-lock.json
COPY package*.json ./
RUN npm ci

# Copier le dossier Prisma et générer le client Prisma
COPY prisma ./prisma
RUN npx prisma generate

# Copier le code source et le dossier seed
COPY src ./src
COPY seed ./seed

# Vérifier la syntaxe du code
RUN npm run build

# ---------- Production stage ----------
FROM node:18-alpine

WORKDIR /app
ENV NODE_ENV=production

# Installer runtime libs pour Prisma
RUN apk add --no-cache libc6-compat openssl

# Copier les dépendances
COPY package*.json ./
RUN npm ci --only=production

# Copier le client Prisma depuis le builder
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

# Copier le code compilé, Prisma schema et seed
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/seed ./seed

EXPOSE 3000

CMD ["node", "dist/index.js"]