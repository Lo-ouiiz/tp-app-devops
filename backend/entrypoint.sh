set -e  # Quitte si une commande échoue

echo "Attente de la base PostgreSQL..."
sleep 5

echo "Appliquer les migrations Prisma..."
npx prisma migrate deploy

echo "Seed de la base..."
node seed/seed.js

echo "Démarrage du serveur..."
exec node dist/index.js
