import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import * as amqp from 'amqplib';
import { ENV } from '../common/constants';

@Injectable()
export class RabbitMQService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RabbitMQService.name);
  private connection: any = null;
  private channel: any = null;

  async onModuleInit(): Promise<void> {
    try {
      this.connection = await amqp.connect(ENV.RABBITMQ_URL);
      this.channel = await this.connection.createChannel();
      this.logger.log('RabbitMQ connected');
    } catch (err) {
      this.logger.error('Failed to connect to RabbitMQ', err);
      throw err;
    }
  }

  async onModuleDestroy(): Promise<void> {
    if (this.channel) {
      await this.channel.close();
      this.channel = null;
    }
    if (this.connection) {
      await this.connection.close();
      this.connection = null;
    }
  }

  getChannel(): amqp.Channel {
    if (!this.channel) {
      throw new Error('RabbitMQ channel not initialized');
    }
    return this.channel;
  }

  async assertExchange(params: {
    channel: amqp.Channel;
    exchange: string;
  }): Promise<void> {
    const { channel, exchange } = params;
    await channel.assertExchange(exchange, 'topic', { durable: true });
  }

  async assertQueue(params: {
    channel: amqp.Channel;
    queueName: string;
  }): Promise<void> {
    const { channel, queueName } = params;
    await channel.assertQueue(queueName, { durable: true, maxPriority: 10 });
  }

  async bindQueue(params: {
    channel: amqp.Channel;
    queueName: string;
    exchange: string;
    routingKey: string;
  }): Promise<void> {
    const { channel, queueName, exchange, routingKey } = params;
    await channel.bindQueue(queueName, exchange, routingKey);
  }
}
