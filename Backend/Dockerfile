FROM node:20-alpine

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy the rest of the application code
COPY . .

# Expose the port specified in your code (defaulting to 5000)
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
