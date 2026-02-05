import { DiffEntry } from './audit.types';

function normalize(val: string | number | null | undefined): string {
  if (val === undefined || val === null) return '';
  return String(val);
}

/**
 * Generic diff function – Sproc_Audit_Generic_Update equivalent.
 * Compares old and new formatted JSON, returns array of changed fields.
 */
export function diffFormattedJSON(
  oldJson: Record<string, string | number | null> | null,
  newJson: Record<string, string | number | null> | null,
): DiffEntry[] {
  const diffs: DiffEntry[] = [];

  const keys = new Set([
    ...Object.keys(oldJson ?? {}),
    ...Object.keys(newJson ?? {}),
  ]);

  for (const key of keys) {
    const oldVal = normalize(oldJson ? oldJson[key] : '');
    const newVal = normalize(newJson ? newJson[key] : '');

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
