// backend/src/sms/sms.service.ts
import { Injectable } from '@nestjs/common';
import { Twilio } from 'twilio';
import { CacheService } from '../cache/cache.service';

@Injectable()
export class SmsService {
  private client: Twilio;

  constructor(private readonly cacheService: CacheService) {
    // Use environment variables from chimbo/.env
    const accountSid = process.env.TWILIO_ACCOUNT_SID!;
    const authToken = process.env.TWILIO_AUTH_TOKEN!;
    this.client = new Twilio(accountSid, authToken);
  }

  async sendSms(to: string, message: string) {
    const cacheKey = `sms:${to}:${message}`;

    // Check if this SMS was sent recently
    const cached = await this.cacheService.get(cacheKey);
    if (cached) {
      console.log(`SMS to ${to} skipped (cached)`);
      return { status: 'skipped', reason: 'cached' };
    }

    // Send SMS
    const result = await this.client.messages.create({
      body: message,
      from: process.env.TWILIO_PHONE_NUMBER!, // must be defined in .env
      to,
    });

    // Cache for 60 seconds to prevent spamming
    await this.cacheService.set(cacheKey, 'sent', 60);

    return result;
  }
}
