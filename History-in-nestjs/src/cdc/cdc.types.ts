import { OperationType } from '../common/enums';

/**
 * Debezium source metadata from CDC payload.
 */
export interface DebeziumSource {
  readonly table: string;
  readonly txId: string;
}

/**
 * Debezium CDC payload with before/after row data.
 */
export interface DebeziumPayload<T = Record<string, unknown>> {
  readonly before: T | null;
  readonly after: T | null;
  readonly op: OperationType;
  readonly source: DebeziumSource;
}

/**
 * Debezium CDC event wrapper.
 */
export interface DebeziumEvent<T = Record<string, unknown>> {
  readonly payload: DebeziumPayload<T>;
}
