FROM node:20.18.1-alpine3.20 AS build

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

COPY package*.json ./

RUN npm ci && \
    npm cache clean --force

COPY --chown=nodejs:nodejs . .

USER nodejs

RUN npm run build

FROM nginx:1.27.3-alpine3.20

RUN addgroup -g 1001 -S nginx-app && \
    adduser -S nginx-app -u 1001

COPY --from=build --chown=nginx-app:nginx-app /app/build /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chown -R nginx-app:nginx-app /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

USER nginx-app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
