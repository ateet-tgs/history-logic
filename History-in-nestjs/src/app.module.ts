import { Module } from '@nestjs/common';
import { SequelizeModule } from './database/sequelize.module';
import { RabbitMQModule } from './rabbitmq/rabbitmq.module';
import { CdcModule } from './cdc/cdc.module';

@Module({
  imports: [SequelizeModule, RabbitMQModule, CdcModule],
})
export class AppModule {}
