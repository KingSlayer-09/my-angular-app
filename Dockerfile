# ---- build stage ----
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Make a prod build to /app/dist/<project-name>
RUN npx ng build --configuration production

# ---- runtime stage ----
FROM nginx:alpine
# SPA routing & caching
COPY nginx.conf /etc/nginx/conf.d/default.conf
# change <project-name> to your actual dist folder name if different
COPY --from=build /app/dist/my-angular-project /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1
