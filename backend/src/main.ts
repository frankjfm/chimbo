// src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';  // ✅ correct relative path
import * as dotenv from 'dotenv';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  dotenv.config({ path: '../.env' });

  const app = await NestFactory.create(AppModule);

  app.enableCors();

  const port = parseInt(process.env.PORT || '3000', 10);

  try {
    await app.listen(port, '0.0.0.0');
    Logger.log(`Application is running on: http://0.0.0.0:${port}`);
  } catch (err) {
    Logger.error('Failed to start the application', err);
  }
}

bootstrap();

