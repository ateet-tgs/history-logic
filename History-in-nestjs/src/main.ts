import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['log', 'error', 'warn', 'debug'],
  });

  const logger = new Logger('Bootstrap');
  logger.log('CDC Audit Microservice started (no HTTP)');
}

bootstrap().catch((err) => {
  console.error('Failed to start application', err);
  process.exit(1);
});
