import { Module } from '@nestjs/common';
import { RabbitMQModule } from '../rabbitmq/rabbitmq.module';
import { AuditModule } from '../audit/audit.module';
import { CdcConsumer } from './cdc.consumer';

@Module({
  imports: [RabbitMQModule, AuditModule],
  providers: [CdcConsumer],
})
export class CdcModule {}
