"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsService = void 0;
const common_1 = require("@nestjs/common");
const twilio_1 = require("twilio");
const cache_service_1 = require("../cache/cache.service");
let SmsService = class SmsService {
    constructor(cacheService) {
        this.cacheService = cacheService;
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        this.client = new twilio_1.Twilio(accountSid, authToken);
    }
    async sendSms(to, message) {
        const cacheKey = `sms:${to}:${message}`;
        const cached = await this.cacheService.get(cacheKey);
        if (cached) {
            console.log(`SMS to ${to} skipped (cached)`);
            return { status: 'skipped', reason: 'cached' };
        }
        const result = await this.client.messages.create({
            body: message,
            from: process.env.TWILIO_PHONE_NUMBER,
            to,
        });
        await this.cacheService.set(cacheKey, 'sent', 60);
        return result;
    }
};
exports.SmsService = SmsService;
exports.SmsService = SmsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [cache_service_1.CacheService])
], SmsService);
//# sourceMappingURL=sms.service.js.map