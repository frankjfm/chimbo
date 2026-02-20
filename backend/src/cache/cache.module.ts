// src/cache/cache.module.ts
// backend/src/cache/cache.module.ts
import { Module, Global } from '@nestjs/common';
import { CacheService } from './cache.service';

@Global() // Make CacheService available globally
@Module({
  providers: [CacheService],
  exports: [CacheService],
})
export class CacheModule {}
