/**
 * Single diff entry between old and new formatted JSON.
 */
export interface DiffEntry {
  columnName: string;
  oldValue: string | null;
  newValue: string | null;
}

/**
 * Result of formatRow - rowData for diffing and tableData for audit insert.
 */
export interface FormatRowResult {
  rowData: Record<string, string | number | null>;
  tableData: {
    rootTableName: string;
    rootRefId: number;
  } | null;
}

/**
 * Context JSON resolved from registry queries.
 */
export type ContextJSON = Record<string, string | number | null>;

/**
 * Context query definition with parameterized SQL and mapper.
 */
export interface ContextQueryDef<TRow = Record<string, unknown>> {
  query: string;
  map: (row: TRow) => string | number | null;
}

/**
 * Audit context config for a table.
 */
export interface AuditContextConfig {
  entityLevel: number;
  root: {
    table: string;
    refField: string;
  };
  context: Record<string, ContextQueryDef<any>>;
}

/**
 * Registry of table name to audit context config.
 */
export type AuditContextRegistry = Record<string, AuditContextConfig>;

export interface InsertAuditLogsParams {
  tableName: string;
  rootTableName: string | null;
  rootRefId: number | null;
  refTransId: string;
  entityLevel: number;
  entityDisplayRef: string;
  updatedAt: string | Date | null;
  Updatedby: number | null;
  updateByRoleId: number | null;
  diffs: DiffEntry[];
  contextJSON: ContextJSON | null;
}