# Stage 1: Build-stage
FROM node:22-alpine AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Build โดยใช้ Placeholder ทิ้งไว้ในไฟล์ JS เพื่อรอการแทนที่ตอน Run
RUN VITE_GRAPHQL_URI=__VITE_GRAPHQL_URI_PLACEHOLDER__ \
    VITE_SERVER_URI=__VITE_SERVER_URI_PLACEHOLDER__ \
    npm run build -- --mode production

# Stage 2: Production-stage
FROM nginx:alpine AS production-stage

COPY nginx-custom.conf /etc/nginx/conf.d/default.conf

# ก๊อปปี้ไฟล์ที่ Build เสร็จแล้วไปที่โฟลเดอร์ของ Nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html

# เพิ่มสคริปต์สำหรับแทนที่ Placeholder
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]