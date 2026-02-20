// backend/src/cache/cache.service.ts
import { Injectable } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class CacheService {
  private redis: Redis;

  constructor() {
    // Read Redis config from root .env
    const host = process.env.REDIS_HOST || 'redis_cache';
    const port = process.env.REDIS_PORT ? parseInt(process.env.REDIS_PORT, 10) : 6379;

    this.redis = new Redis({
      host, // guaranteed string
      port, // guaranteed number
    });
  }

  async set(key: string, value: string, ttl = 60) {
    // Set value with TTL in seconds
    await this.redis.set(key, value, 'EX', ttl);
  }

  async get(key: string) {
    return this.redis.get(key);
  }
}
