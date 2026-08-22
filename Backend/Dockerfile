FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy the rest of the backend code
COPY . .

# Expose the port specified in your code
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
