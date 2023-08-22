FROM node:18

WORKDIR /app

# Clone the Lodestar repository
#RUN git clone https://github.com/ChainSafe/lodestar.git .

# Install yarn
RUN npm install --global yarn

# Install cmdtest
RUN apt update && apt install -y cmdtest

# Install dependencies and build lodestar
RUN yarn install && yarn run build