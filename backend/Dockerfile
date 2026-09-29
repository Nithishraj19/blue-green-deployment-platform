FROM node:22-alpine
WORKDIR /app
COPY --chown=node:node backend/server.js ./server.js
USER node
ENV PORT=8081
EXPOSE 8081
CMD ["node","server.js"]
