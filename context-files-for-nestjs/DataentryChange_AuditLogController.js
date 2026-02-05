const _ = require('lodash');
const { DATA_CONSTANT } = require('../../../constant');

const { rabbitmqAssertQueue } = require("../../../utils/rabbitmq");
const {
  formatRow,
  diffFormattedJSON,
  insertAuditLogsSequelize,
  resolveContextJSON,
} = require("./diffFormattedJSON");
const models = require("../../../models");

module.exports = {
  cdcHistoryRequest: (channel) => {
    const queue = DATA_CONSTANT.SERVICE_QUEUE_PART.CDC_HISTORY_QUEUE;
    rabbitmqAssertQueue({
      channel,
      queueName: queue,
    });

    channel.consume(queue, async (msg) => {
      try {
        const content = msg.content.toString("utf8");
        const event = JSON.parse(content);

        const { payload } = event;
        const { before, after, op, source } = payload;
        const tableName = source.table;

        console.log("TABLE:", tableName);
        console.log("OP:", op);

        let oldFormatted = null;
        let newFormatted = null;
        let tableData = null;
        const contextJSON = await resolveContextJSON({
          sequelize: models.sequelize,
          tableName,
          row: after,
        });

        // INSERT
        if (op === "c") {
          oldFormatted = {}; // matches empty OLD JSON in trigger
          const newFormattedData = formatRow(tableName, after, op);
          newFormatted = newFormattedData?.rowData;
          tableData = newFormattedData?.tableData;
        }

        // UPDATE
        else if (op === "u") {
          oldFormatted = formatRow(tableName, before, op)?.rowData;
          const newFormattedData = formatRow(tableName, after, op);
          newFormatted = newFormattedData?.rowData;
          tableData = newFormattedData?.tableData;
        }

        // DELETE (optional)
        else if (op === "d") {
          oldFormatted = {};
          newFormatted = {};
        }

        if (oldFormatted && newFormatted) {
          const diffs = diffFormattedJSON(oldFormatted, newFormatted);

          if (diffs.length) {
            await insertAuditLogsSequelize({
              sequelize: models.sequelize,
              tableName,
              rootTableName: tableData?.rootTableName,
              rootRefId: tableData?.rootRefId ?? after?.id ?? null,
              refTransId: source.txId,
              entityLevel: 0,
              entityDisplayRef: tableName,
              updatedAt: after?.updatedAt,
              Updatedby: after?.updatedBy,
              updateByRoleId: after?.updateByRoleId,
              diffs,
              contextJSON,
            });
          }
        }

        channel.ack(msg);
      } catch (err) {
        console.error("CDC processing failed:", err);
        // do NOT ack → message will retry
      }
    });
  },
};