FROM node:alpine
WORKDIR /usr/shr/app
COPY . .
RUN npm install
CMD ["npm", "start"]
EXPOSE 8080