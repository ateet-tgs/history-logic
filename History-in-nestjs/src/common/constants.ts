/**
 * Typed environment variable access.
 * All external configuration must be read from process.env.
 */
export const ENV = {
  get RABBITMQ_URL() {
    return process.env.RABBITMQ_URL ?? 'amqp://localhost/Q2C_DEV_HOST_CDCHISTORY';
  },
  get DB_HOST() {
    return process.env.DB_HOST ?? 'localhost';
  },
  get DB_USER() {
    return process.env.DB_USER ?? 'root';
  },
  get DB_PASS() {
    return process.env.DB_PASS ?? '';
  },
  get DB_NAME() {
    return process.env.DB_NAME ?? 'audit_db';
  },
  get CDC_HISTORY_QUEUE() {
    return process.env.CDC_HISTORY_QUEUE ?? 'cdc_history_queue';
  },
  get CDC_EXCHANGE() {
    return process.env.CDC_EXCHANGE ?? 'cdc_exchange';
  },
  get CDC_ROUTING_KEY() {
    return process.env.CDC_ROUTING_KEY ?? 'cdc.audit';
  },
} as const;

