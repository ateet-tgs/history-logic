import { Injectable, OnModuleInit, Logger } from "@nestjs/common";
import { RabbitMQService } from "../rabbitmq/rabbitmq.service";
import { AuditService } from "../audit/audit.service";
import { ENV } from "../common/constants";
import { DebeziumEvent } from "./cdc.types";
import { OperationType } from "../common/enums";
import { CdcRow } from "../audit/format-row.util";

@Injectable()
export class CdcConsumer implements OnModuleInit {
  private readonly logger = new Logger(CdcConsumer.name);

  constructor(
    private readonly rabbitMQService: RabbitMQService,
    private readonly auditService: AuditService,
  ) {}

  async onModuleInit(): Promise<void> {
    const channel = this.rabbitMQService.getChannel();
    const queue = ENV.CDC_HISTORY_QUEUE;
    const exchange = ENV.CDC_EXCHANGE;
    const routingKey = ENV.CDC_ROUTING_KEY;

    try {
      await this.rabbitMQService.assertExchange({
        channel,
        exchange,
      });
      await this.rabbitMQService.assertQueue({
        channel,
        queueName: queue,
      });
      await this.rabbitMQService.bindQueue({
        channel,
        queueName: queue,
        exchange,
        routingKey,
      });
      this.logger.log(
        `Queue ${queue} bound to exchange ${exchange} with routing key ${routingKey}`,
      );
    } catch (error) {
      this.logger.error("Failed to setup queue", error);
    }

    channel.consume(queue, async (msg) => {
      if (!msg) return;
      const headers = msg.properties.headers ?? {};
      const retryCount = Number(headers["x-retry-count"] ?? 0);
      const MAX_RETRIES = 3;

      try {
        const content = msg.content.toString("utf8");
        const event = JSON.parse(content) as DebeziumEvent<CdcRow>;

        const { payload } = event;
        const { before, after, op, source } = payload;
        const tableName = source.table;

        this.logger.debug(`TABLE: ${tableName}, OP: ${op}`);

        let oldFormatted: Record<string, string | number | null> | null = null;
        let newFormatted: Record<string, string | number | null> | null = null;
        let tableData: { rootTableName: string; rootRefId: number } | null =
          null;

        const contextJSON = await this.auditService.resolveContextJSON(
          tableName,
          after,
        );

        if (op === OperationType.INSERT) {
          oldFormatted = {};
          const newFormattedData = this.auditService.formatRow(
            tableName,
            after,
            op,
          );
          newFormatted = newFormattedData?.rowData ?? null;
          tableData = newFormattedData?.tableData ?? null;
        } else if (op === OperationType.UPDATE) {
          const oldFormattedData = this.auditService.formatRow(
            tableName,
            before,
            op,
          );
          oldFormatted = oldFormattedData?.rowData ?? null;
          const newFormattedData = this.auditService.formatRow(
            tableName,
            after,
            op,
          );
          newFormatted = newFormattedData?.rowData ?? null;
          tableData = newFormattedData?.tableData ?? null;
        } else if (op === OperationType.DELETE) {
          oldFormatted = {};
          newFormatted = {};
        }

        if (oldFormatted !== null && newFormatted !== null) {
          const diffs = this.auditService.diffFormattedJSON(
            oldFormatted,
            newFormatted,
          );

          if (diffs.length > 0) {
            const rootRefId = tableData?.rootRefId ?? after?.id ?? null;
            const rootTableName = tableData?.rootTableName ?? null;

            await this.auditService.insertAuditLogs({
              tableName,
              rootTableName,
              rootRefId: rootRefId != null ? rootRefId : null,
              refTransId: source.txId ?? after?.id,
              entityLevel: 0,
              entityDisplayRef: tableName,
              updatedAt: after?.updatedAt ?? null,
              Updatedby: after?.updatedBy ?? null,
              updateByRoleId: after?.updateByRoleId ?? null,
              diffs,
              contextJSON,
            });
          }
        }

        channel.ack(msg);
      } catch (err) {
        this.logger.error("CDC processing failed", err);
        if (retryCount < MAX_RETRIES) {
          // 🔁 REPUBLISH with incremented retry count
          channel.publish(ENV.CDC_EXCHANGE, ENV.CDC_ROUTING_KEY, msg.content, {
            headers: {
              ...headers,
              "x-retry-count": retryCount + 1,
            },
            persistent: true,
          });
        } else {
          // ☠️ SEND TO DLQ
          // channel.sendToQueue(ENV.CDC_HISTORY_DLQ, msg.content, {
          //   headers: {
          //     ...headers,
          //     "x-retry-count": retryCount,
          //     "x-error": err.message,
          //   },
          //   persistent: true,
          // });
        }

        // ✅ ALWAYS ACK original message
        channel.ack(msg);
      }
    });
  }
}
