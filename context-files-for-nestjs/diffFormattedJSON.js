const auditContextRegistry = require("./auditContextRegistry");

function normalize(val) {
  if (val === undefined || val === null) return "";
  return String(val);
}

/**
 * Generic diff function – Sproc_Audit_Generic_Update equivalent
 */
function diffFormattedJSON(oldJson, newJson) {
  const diffs = [];

  const keys = new Set([
    ...Object.keys(oldJson || {}),
    ...Object.keys(newJson || {}),
  ]);

  for (const key of keys) {
    const oldVal = normalize(oldJson ? oldJson[key] : "");
    const newVal = normalize(newJson ? newJson[key] : "");

    if (oldVal !== newVal) {
      diffs.push({
        columnName: key,
        oldValue: oldVal || null,
        newValue: newVal || null,
      });
    }
  }

  return diffs;
}

function formatRow(table, row, operation) {
  if (!row) return null;

  switch (table) {
    case "rfq_rohsmst": {
      return {
        rowData: {
          name: row.name,
          description: row.description,
          isActive: row.isActive === 1 ? "Active" : "Inactive",
          rohsIcon: row.rohsIcon,
          refMainCategoryID: row.refMainCategoryID,
          refParentID: row.refParentID,
          displayOrder: row.displayOrder,
          sourceName: row.sourceName,
        },
        tableData: {
          rootTableName: "rfq_rohsmst",
          rootRefId: row.id,
        },
      };
    }

    case "rfq_rohsmst_peer": {
      const operations = ["c", "u"];
      if (operations.includes(operation)) {
        return {
          rowData: {
            rohsPeerID:
              operation === "u" && row.isDeleted === 1 ? "" : row.rohsPeerID,
          },
          tableData: {
            rootTableName: "rfq_rohsmst",
            rootRefId: row.rohsID,
          },
        };
      } else {
        return null;
      }
    }

    case "component_fields_genericalias_mst": {
      const operations = ["c", "u"];
      if (
        operations.includes(operation) &&
        row.refTableName === "rfq_rohsmst"
      ) {
        return {
          rowData: {
            alias: operation === "u" && row.isDeleted === 1 ? "" : row.alias,
          },
          tableData: {
            rootTableName: "rfq_rohsmst",
            rootRefId: row.refId,
          },
        };
      } else {
        return null;
      }
    }

    case "salesorderdet":
      return {
        rowData: {
          qty: row.qty,
          price: row.price != null ? Number(row.price).toFixed(8) : "",
          extendedPrice:
            row.extendedPrice != null
              ? Number(row.extendedPrice).toFixed(8)
              : "",
          remark: row.remark,
          isHotJob: row.isHotJob === 1 ? "Yes" : "No",
          isCancle: row.isCancle === 1 ? "Yes" : "No",
          partDescription: row.partDescription,
          // add only fields you audit (same as trigger)
        },
        tableData: {
          rootTableName: "salesordermst",
          rootRefId: row.refId,
        },
      };

    default:
      return { rowData: row, tableData: null }; // fallback (raw)
  }
}

async function insertAuditLogsSequelize({
  sequelize, // instance of Sequelize
  tableName,
  rootTableName,
  rootRefId,
  refTransId,
  entityLevel,
  entityDisplayRef,
  updatedAt,
  Updatedby,
  updateByRoleId,
  diffs,
  contextJSON, // optional
}) {
  // 1 Filter diffs by audit metadata
  const insertRows = diffs.map((d) => ({
    rootTableName,
    rootRefId,
    TableName: tableName,
    RefTransID: refTransId,
    entityLevel,
    entityDisplayRef,
    Colname: d.columnName,
    Oldval: d.oldValue,
    Newval: d.newValue,
    updatedAt: new Date(updatedAt),
    Updatedby,
    updateByRoleId,
  }));

  if (!insertRows.length) return [];

  // 2 Bulk insert using Sequelize
  const result = await sequelize.getQueryInterface().bulkInsert(
    "dataentrychange_auditlog",
    insertRows,
    { returning: true }, // get inserted IDs (Postgres/MySQL 8+)
  );

  // Sequelize bulkInsert in MySQL may not return IDs, so emulate:
  const firstId = result?.insertId ?? 0;
  const auditIds = insertRows.map((_, i) => firstId + i);

  // 3 Optional: insert context snapshot
  if (contextJSON && auditIds.length) {
    await insertContextSnapshotsSequelize({
      sequelize,
      auditIds,
      tableName,
      contextJSON,
    });
  }

  return auditIds;
}

async function insertContextSnapshotsSequelize({
  sequelize,
  auditIds,
  tableName,
  contextJSON,
}) {
  const contextRows = [];

  for (const [key, value] of Object.entries(contextJSON)) {
    const meta = null;
    if (!meta || meta.isContextField !== 1) continue;

    auditIds.forEach((auditId) => {
      contextRows.push({
        auditLogId: auditId,
        contextField: key,
        contextValue: value,
      });
    });
  }

  if (!contextRows.length) return;

  await sequelize
    .getQueryInterface()
    .bulkInsert("audit_change_context_snapshot", contextRows);
}

async function resolveContextJSON({ sequelize, tableName, row }) {
  const config = auditContextRegistry[tableName];
  if (!config || !config.context) return null;

  const contextJSON = {};

  // Resolve rootId generically
  const rootId = config.root?.refField ? row[config.root.refField] : row.id;

  for (const [key, def] of Object.entries(config.context)) {
    const [result] = await sequelize.query(def.query, {
      replacements: { rootId },
      type: sequelize.QueryTypes.SELECT,
    });

    contextJSON[key] = result ? def.map(result) : null;
  }

  return contextJSON;
}

module.exports = {
  diffFormattedJSON,
  formatRow,
  insertAuditLogsSequelize,
  resolveContextJSON,
};
