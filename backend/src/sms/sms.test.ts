import * as dotenv from 'dotenv';
dotenv.config();

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { SmsService } from './sms.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);

  const smsService = app.get(SmsService);

  try {
    const result = await smsService.sendSms(
      '+255683536539',
      'Chimbo SMS test'
    );

    console.log('Result:', result);
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await app.close();
  }
}

bootstrap();
