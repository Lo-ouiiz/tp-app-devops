# ---------- Build stage ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Installer runtime libs pour Prisma
RUN apk add --no-cache libc6-compat openssl

COPY package*.json ./
RUN npm ci

# Copier le dossier Prisma et générer le client Prisma
COPY prisma ./prisma
RUN npx prisma generate

COPY src ./src
COPY seed ./seed

RUN npm run build

# ---------- Production stage ----------
FROM node:18-alpine

WORKDIR /app
ENV NODE_ENV=production

# Installer runtime libs pour Prisma
RUN apk add --no-cache libc6-compat openssl bash curl

COPY package*.json ./
RUN npm ci --only=production

# Copier Prisma client et node_modules
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/seed ./seed

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 3000

# Utiliser l'entrypoint pour lancer les migrations, seed et serveur
CMD ["./entrypoint.sh"]
