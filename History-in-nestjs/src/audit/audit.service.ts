import { Inject, Injectable } from '@nestjs/common';
import { Sequelize } from 'sequelize';
import { QueryTypes } from 'sequelize';
import { SEQUELIZE } from '../database/sequelize.module';
import { AUDIT_CONTEXT_REGISTRY } from './audit-context.registry';
import { diffFormattedJSON } from './diff.util';
import { formatRow } from './format-row.util';
import { CdcRow } from './format-row.util';
import { ContextJSON, DiffEntry, FormatRowResult, InsertAuditLogsParams } from './audit.types';
import { OperationType } from '../common/enums';

interface DataEntryChangeAuditLogRow {
  rootTableName: string | null;
  rootRefId: number | null;
  TableName: string;
  RefTransID: string;
  entityLevel: number;
  entityDisplayRef: string;
  Colname: string;
  Oldval: string | null;
  Newval: string | null;
  updatedAt: Date;
  Updatedby: number | null;
  updateByRoleId: number | null;
}

@Injectable()
export class AuditService {
  constructor(
    @Inject(SEQUELIZE)
    private readonly sequelize: Sequelize,
  ) {}

  formatRow(
    table: string,
    row: CdcRow | null,
    operation: OperationType,
  ): FormatRowResult | null {
    return formatRow(table, row, operation);
  }

  diffFormattedJSON(
    oldJson: Record<string, string | number | null> | null,
    newJson: Record<string, string | number | null> | null,
  ): DiffEntry[] {
    return diffFormattedJSON(oldJson, newJson);
  }

  async resolveContextJSON(
    tableName: string,
    row: CdcRow | null,
  ): Promise<ContextJSON | null> {
    const config = AUDIT_CONTEXT_REGISTRY[tableName];
    if (!config || !config.context) return null;

    if (row === null || row === undefined) return null;

    const contextJSON: ContextJSON = {};

    const rootId = config.root?.refField
      ? (row[config.root.refField] as number | undefined)
      : row.id;

    for (const [key, def] of Object.entries(config.context)) {
      const results = await this.sequelize.query<Record<string, unknown>>(
        def.query,
        {
          replacements: { rootId },
          type: QueryTypes.SELECT,
        },
      );
      const result = results[0] ?? null;
      contextJSON[key] = result
        ? (def as { map: (row: Record<string, unknown>) => string | number | null }).map(
            result,
          )
        : null;
    }

    return contextJSON;
  }

  async insertAuditLogs(params: InsertAuditLogsParams): Promise<number[]> {
    const {
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
      contextJSON,
    } = params;

    const insertRows: DataEntryChangeAuditLogRow[] = diffs.map((d) => ({
      rootTableName,
      rootRefId,
      TableName: tableName,
      RefTransID: refTransId,
      entityLevel,
      entityDisplayRef,
      Colname: d.columnName,
      Oldval: d.oldValue,
      Newval: d.newValue,
      updatedAt: new Date(updatedAt ?? Date.now()),
      Updatedby,
      updateByRoleId,
    }));

    if (insertRows.length === 0) return [];

    const queryInterface = this.sequelize.getQueryInterface();
    const result = await queryInterface.bulkInsert(
      'dataentrychange_auditlog',
      insertRows,
    );

    const rawResult = result as { insertId?: number } | undefined;
    const firstId = rawResult?.insertId ?? 0;
    const auditIds = insertRows.map((_, i) => firstId + i);

    if (contextJSON && auditIds.length > 0) {
      await this.insertContextSnapshotsSequelize(
        auditIds,
        tableName,
        contextJSON,
      );
    }

    return auditIds;
  }

  /**
   * Inserts context snapshots into audit_change_context_snapshot.
   * Legacy behavior: meta is always null, so the loop never pushes rows.
   * Context snapshots are effectively never inserted.
   * Preserved for behavioral parity; can be fixed by introducing real metadata.
   */
  private async insertContextSnapshotsSequelize(
    auditIds: number[],
    tableName: string,
    contextJSON: ContextJSON,
  ): Promise<void> {
    const contextRows: Array<{
      auditLogId: number;
      contextField: string;
      contextValue: string | number | null;
    }> = [];

    for (const [key, value] of Object.entries(contextJSON)) {
      // Legacy: meta is always null, skip context insertion
      continue;

      for (const auditId of auditIds) {
        contextRows.push({
          auditLogId: auditId,
          contextField: key,
          contextValue: value,
        });
      }
    }

    if (contextRows.length === 0) return;

    await this.sequelize
      .getQueryInterface()
      .bulkInsert('audit_change_context_snapshot', contextRows);
  }
}
