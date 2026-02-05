import {
  AuditContextConfig,
  AuditContextRegistry,
  ContextQueryDef,
} from './audit.types';

interface SalesordermstRow {
  revision: string | number | null;
}

const salesorderdetContext: Record<string, ContextQueryDef<SalesordermstRow>> = {
  soRevision: {
    query: `
      SELECT revision
      FROM salesordermst
      WHERE id = :rootId
    `,
    map: (row: SalesordermstRow): string | number | null => row.revision,
  },
};

/**
 * Declarative audit context registry.
 * Supports 150+ tables with no code duplication.
 */
export const AUDIT_CONTEXT_REGISTRY: AuditContextRegistry = {
  salesorderdet: {
    entityLevel: 2,
    root: {
      table: 'salesordermst',
      refField: 'refSalesOrderID',
    },
    context: salesorderdetContext,
  },
};
