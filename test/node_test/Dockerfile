FROM node
MAINTAINER Elliot Saba <staticfloat@gmail.com>

RUN git clone https://github.com/23/resumable.js.git /app
WORKDIR /app/samples/Node.js/
RUN npm install

EXPOSE 3000
CMD ["node", "app.js"]
