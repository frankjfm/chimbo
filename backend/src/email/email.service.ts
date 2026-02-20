import { Injectable } from '@nestjs/common';
import sgMail from '@sendgrid/mail';

@Injectable()
export class EmailService {
  constructor() {
    if (!process.env.SENDGRID_API_KEY) {
      throw new Error('SENDGRID_API_KEY is not defined in .env');
    }

    sgMail.setApiKey(process.env.SENDGRID_API_KEY);
  }

  async sendEmail(to: string, subject: string, text: string) {
    const msg = {
      to,
      from: process.env.SENDGRID_FROM_EMAIL!, // must exist in .env
      subject,
      text,
    };

    return sgMail.send(msg);
  }
}
