export interface TableProps {
	/** Names the table and its scroll region. */
	caption: string;
	columns: string[];
	rows: Array<Array<string | number>>;
}

/** Table (DSP-02), basic variant: a static content table. No client JavaScript needed. */
export function Table({ caption, columns, rows }: TableProps) {
	return (
		<section
			className="px-table-wrap"
			// biome-ignore lint/a11y/noNoninteractiveTabindex: a scrollable region must be keyboard-focusable to scroll it; Safari does not make scroll containers focusable by default.
			tabIndex={0}
			aria-label={caption}
		>
			<table className="px-table">
				<caption>{caption}</caption>
				<thead>
					<tr>
						{columns.map((c) => (
							<th key={c} scope="col">
								{c}
							</th>
						))}
					</tr>
				</thead>
				<tbody>
					{rows.map((r, i) => (
						// biome-ignore lint/suspicious/noArrayIndexKey: rows are static content, never reordered, inserted or removed.
						<tr key={i}>
							{r.map((cell, j) => (
								// biome-ignore lint/suspicious/noArrayIndexKey: cells follow fixed column positions.
								<td key={j}>{cell}</td>
							))}
						</tr>
					))}
				</tbody>
			</table>
		</section>
	);
}
