// Type-level tests, checked by `pnpm typecheck` (tsconfig.test.json), not run by vitest.
import { Button } from '../src/index.js';

export const disabledLink = (
	// @ts-expect-error a link has no disabled state
	<Button href="/" disabled>
		Home
	</Button>
);
export const submitLink = (
	// @ts-expect-error a link has no button type
	<Button href="/" type="submit">
		Home
	</Button>
);
export const okLink = (
	<Button href="/" target="_blank">
		Home
	</Button>
);
export const okButton = (
	<Button type="submit" disabled>
		Save
	</Button>
);
