# Audit System

This is an audit system that processes database changes using Debezium for Change Data Capture (CDC) and RabbitMQ for message queuing.

## Setup

1. Install dependencies: `npm install`

2. Set up environment variables in `.env`

3. Run setup script: `npm run setup`

4. Start RabbitMQ and Debezium services using Docker: `docker-compose up`

5. Start the application: `npm start`

## Structure

- `src/`: Source code
- `docker/`: Docker configurations
- `sql/`: SQL scripts
- `scripts/`: Setup scripts