import { OperationType } from '../common/enums';
import { FormatRowResult } from './audit.types';

/**
 * CDC row shape - optional fields for all known tables.
 * Used to satisfy strict typing without any.
 */
export interface CdcRow {
  id?: number;
  refId?: number;
  rohsID?: number;
  refSalesOrderID?: number;
  refTableName?: string;
  isDeleted?: number;
  name?: string;
  description?: string;
  isActive?: number;
  rohsIcon?: string | null;
  refMainCategoryID?: number | null;
  refParentID?: number | null;
  displayOrder?: number | null;
  sourceName?: string | null;
  rohsPeerID?: string | null;
  alias?: string | null;
  qty?: number | null;
  price?: number | string | null;
  extendedPrice?: number | string | null;
  remark?: string | null;
  isHotJob?: number;
  isCancle?: number;
  partDescription?: string | null;
  updatedAt?: string | Date | null;
  updatedBy?: number | null;
  updateByRoleId?: number | null;
  [key: string]: string | number | Date | null | undefined;
}

/**
 * Format a CDC row for audit diffing.
 * Preserves exact legacy switch/case logic and operation-based behavior.
 */
export function formatRow(
  table: string,
  row: CdcRow | null,
  operation: OperationType,
): FormatRowResult | null {
  if (!row) return null;

  switch (table) {
    case 'rfq_rohsmst': {
      return {
        rowData: {
          name: row.name ?? null,
          description: row.description ?? null,
          isActive: row.isActive === 1 ? 'Active' : 'Inactive',
          rohsIcon: row.rohsIcon ?? null,
          refMainCategoryID: row.refMainCategoryID ?? null,
          refParentID: row.refParentID ?? null,
          displayOrder: row.displayOrder ?? null,
          sourceName: row.sourceName ?? null,
        },
        tableData: {
          rootTableName: 'rfq_rohsmst',
          rootRefId: row.id ?? 0,
        },
      };
    }

    case 'rfq_rohsmst_peer': {
      const operations: OperationType[] = [OperationType.INSERT, OperationType.UPDATE];
      if (operations.includes(operation)) {
        return {
          rowData: {
            rohsPeerID:
              operation === OperationType.UPDATE && row.isDeleted === 1
                ? ''
                : row.rohsPeerID ?? '',
          },
          tableData: {
            rootTableName: 'rfq_rohsmst',
            rootRefId: row.rohsID ?? 0,
          },
        };
      } else {
        return null;
      }
    }

    case 'component_fields_genericalias_mst': {
      const operations: OperationType[] = [OperationType.INSERT, OperationType.UPDATE];
      if (
        operations.includes(operation) &&
        row.refTableName === 'rfq_rohsmst'
      ) {
        return {
          rowData: {
            alias:
              operation === OperationType.UPDATE && row.isDeleted === 1
                ? ''
                : row.alias ?? '',
          },
          tableData: {
            rootTableName: 'rfq_rohsmst',
            rootRefId: row.refId ?? 0,
          },
        };
      } else {
        return null;
      }
    }

    case 'salesorderdet':
      return {
        rowData: {
          qty: row.qty ?? null,
          price: row.price != null ? Number(row.price).toFixed(8) : '',
          extendedPrice:
            row.extendedPrice != null
              ? Number(row.extendedPrice).toFixed(8)
              : '',
          remark: row.remark ?? null,
          isHotJob: row.isHotJob === 1 ? 'Yes' : 'No',
          isCancle: row.isCancle === 1 ? 'Yes' : 'No',
          partDescription: row.partDescription ?? null,
        },
        tableData: {
          rootTableName: 'salesordermst',
          rootRefId: row.refId ?? 0,
        },
      };

    default:
      return {
        rowData: row as Record<string, string | number | null>,
        tableData: null,
      };
  }
}
