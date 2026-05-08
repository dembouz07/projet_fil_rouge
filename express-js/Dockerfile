FROM node:20.18.1-alpine3.20

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production && \
    npm cache clean --force

COPY --chown=nodejs:nodejs . .

USER nodejs

EXPOSE 5000

ENV NODE_ENV=production
ENV PORT=5000

CMD ["node", "app.js"]
