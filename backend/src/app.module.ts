import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SmsModule } from './sms/sms.module';
import { EmailModule } from './email/email.module';
import { CacheModule } from './cache/cache.module';

@Module({
  imports: [
    // Load .env from project root (one level above backend)
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '../.env',
    }),

    // PostgreSQL connection using environment variables
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.POSTGRES_HOST,
      port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
      username: process.env.POSTGRES_USER,
      password: process.env.POSTGRES_PASSWORD,
      database: process.env.POSTGRES_DB,
      autoLoadEntities: true,
      synchronize: true, // ⚠ dev only
    }),

    CacheModule,
    SmsModule,
    EmailModule,
  ],
})
export class AppModule {}
