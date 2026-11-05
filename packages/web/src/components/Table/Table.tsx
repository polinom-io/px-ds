export interface TableProps {
  /** Names the table and its scroll region. */
  caption: string;
  columns: string[];
  rows: Array<Array<string | number>>;
}

/** Table (DSP-02), basic variant: a static content table. No client JavaScript needed. */
export function Table({ caption, columns, rows }: TableProps) {
  return (
    <div className="px-table-wrap" tabIndex={0} role="region" aria-label={caption}>
      <table className="px-table">
        <caption>{caption}</caption>
        <thead>
          <tr>{columns.map((c) => <th key={c} scope="col">{c}</th>)}</tr>
        </thead>
        <tbody>
          {rows.map((r, i) => (
            <tr key={i}>{r.map((cell, j) => <td key={j}>{cell}</td>)}</tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
