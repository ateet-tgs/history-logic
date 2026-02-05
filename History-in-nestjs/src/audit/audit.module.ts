import { Module } from '@nestjs/common';
import { SequelizeModule } from '../database/sequelize.module';
import { AuditService } from './audit.service';

@Module({
  imports: [SequelizeModule],
  providers: [AuditService],
  exports: [AuditService],
})
export class AuditModule {}
