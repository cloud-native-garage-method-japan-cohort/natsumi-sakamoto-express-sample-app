FROM node:20.15.1-bullseye-slim AS base

# === Dependencies layer ===
FROM base AS deps
WORKDIR /app
COPY ./package*.json ./
RUN npm install --ignore-scripts

# === Build layer ===
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# === Runtime layer ===
FROM nginx:1.27 AS runner

COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=builder /app/dist /usr/share/nginx/html

RUN chown -R nginx:nginx /var/cache/nginx && \
    chmod -R g+w /var/cache/nginx

USER nginx

EXPOSE 8080

CMD [ "nginx", "-g", "daemon off;" ]