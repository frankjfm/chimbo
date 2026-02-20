FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Build the app
RUN npm run build

EXPOSE 3000

# Run compiled app (NOT watch mode)
CMD ["node", "dist/main.js"]

