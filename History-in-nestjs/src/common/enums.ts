/**
 * Operation types from Debezium CDC payloads.
 */
export enum OperationType {
  INSERT = 'c',
  UPDATE = 'u',
  DELETE = 'd',
}
