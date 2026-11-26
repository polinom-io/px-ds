import {
	act,
	cleanup,
	fireEvent,
	render,
	screen,
} from '@testing-library/react';
import { createRef } from 'react';
import { afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import {
	Alert,
	Button,
	Field,
	Modal,
	Progress,
	Switch,
	Table,
	Tabs,
} from '../src/index.js';

afterEach(cleanup);

describe('Tabs (WAI-ARIA tabs pattern)', () => {
	const tabs = [
		{ label: 'One', content: 'Panel one' },
		{ label: 'Two', content: 'Panel two' },
		{ label: 'Three', content: 'Panel three' },
	];

	it('has one tab stop and shows only the selected panel', () => {
		render(<Tabs label="Example" tabs={tabs} />);
		const all = screen.getAllByRole('tab');
		expect(all.map((t) => t.tabIndex)).toEqual([0, -1, -1]);
		expect(screen.getByRole('tabpanel')).toHaveProperty(
			'textContent',
			'Panel one',
		);
	});

	it('moves with Right, Left, Home and End, and wraps around', () => {
		render(<Tabs label="Example" tabs={tabs} />);
		const list = screen.getByRole('tablist');
		const selected = () =>
			screen
				.getAllByRole('tab')
				.findIndex((t) => t.getAttribute('aria-selected') === 'true');
		fireEvent.keyDown(list, { key: 'ArrowRight' });
		expect(selected()).toBe(1);
		fireEvent.keyDown(list, { key: 'End' });
		expect(selected()).toBe(2);
		fireEvent.keyDown(list, { key: 'ArrowRight' });
		expect(selected()).toBe(0);
		fireEvent.keyDown(list, { key: 'ArrowLeft' });
		expect(selected()).toBe(2);
		fireEvent.keyDown(list, { key: 'Home' });
		expect(selected()).toBe(0);
		expect(document.activeElement).toBe(screen.getAllByRole('tab')[0]);
	});

	it('leaves other keys alone', () => {
		render(<Tabs label="Example" tabs={tabs} />);
		const list = screen.getByRole('tablist');
		const handled = fireEvent.keyDown(list, { key: 'a' });
		expect(handled).toBe(true);
		expect(screen.getAllByRole('tab')[0]?.getAttribute('aria-selected')).toBe(
			'true',
		);
	});

	it('makes the visible panel focusable', () => {
		render(<Tabs label="Example" tabs={tabs} />);
		expect(screen.getByRole('tabpanel').tabIndex).toBe(0);
	});

	it('links each tab and panel both ways', () => {
		render(<Tabs label="Example" tabs={tabs} />);
		const tab = screen.getAllByRole('tab')[0]!;
		const panel = document.getElementById(tab.getAttribute('aria-controls')!)!;
		expect(panel.getAttribute('aria-labelledby')).toBe(tab.id);
	});
});

describe('Field', () => {
	it('ties label, helper and error to the control', () => {
		render(
			<Field
				label="Email"
				type="email"
				helper="Work address"
				error="Enter a valid email."
			/>,
		);
		const input = screen.getByLabelText('Email');
		expect(input.getAttribute('aria-invalid')).toBe('true');
		const ids = input.getAttribute('aria-describedby')!.split(' ');
		expect(ids.map((id) => document.getElementById(id)?.textContent)).toEqual([
			'Work address',
			'Enter a valid email.',
		]);
	});

	it('has no aria-invalid or describedby when there is nothing to describe', () => {
		render(<Field label="Name" />);
		const input = screen.getByLabelText('Name');
		expect(input.hasAttribute('aria-invalid')).toBe(false);
		expect(input.hasAttribute('aria-describedby')).toBe(false);
	});
});

describe('Alert', () => {
	it('announces warning and danger at once, info and success politely', () => {
		const { rerender } = render(<Alert tone="danger" title="Failed" />);
		expect(screen.getByRole('alert')).toBeTruthy();
		rerender(<Alert tone="success" title="Saved" />);
		expect(screen.getByRole('status')).toBeTruthy();
	});
});

describe('Progress', () => {
	it('clamps the value and prints it', () => {
		render(<Progress label="Upload" value={140} />);
		expect(screen.getByRole('progressbar').getAttribute('aria-valuenow')).toBe(
			'100',
		);
		expect(screen.getByText('100%')).toBeTruthy();
	});
});

describe('Modal', () => {
	beforeAll(() => {
		// jsdom has <dialog> but not showModal()/close(); stand in for the browser.
		HTMLDialogElement.prototype.showModal = vi.fn(function (
			this: HTMLDialogElement,
		) {
			this.setAttribute('open', '');
		});
		HTMLDialogElement.prototype.close = vi.fn(function (
			this: HTMLDialogElement,
		) {
			this.removeAttribute('open');
			this.dispatchEvent(new Event('close'));
		});
	});

	it('opens with showModal() and calls onClose when closed', async () => {
		const onClose = vi.fn();
		const { rerender } = render(
			<Modal open={false} title="Delete this project?" onClose={onClose}>
				Body
			</Modal>,
		);
		const dialog = document.querySelector('dialog')!;
		expect(dialog.open).toBe(false);
		await act(async () => {
			rerender(
				<Modal open title="Delete this project?" onClose={onClose}>
					Body
				</Modal>,
			);
		});
		expect(dialog.open).toBe(true);
		expect(dialog.getAttribute('aria-labelledby')).toBe(
			screen.getByText('Delete this project?').id,
		);
		fireEvent.click(screen.getByLabelText('Close'));
		expect(dialog.open).toBe(false);
		expect(onClose).toHaveBeenCalledTimes(1);
	});
});

describe('Table', () => {
	it('wraps the table in a named, focusable region', () => {
		render(
			<Table caption="Prices" columns={['Item', 'CLP']} rows={[['A', 1000]]} />,
		);
		const region = screen.getByRole('region', { name: 'Prices' });
		expect(region.tabIndex).toBe(0);
		expect(region.querySelector('table')).not.toBeNull();
	});
});

describe('Switch', () => {
	it('exposes the switch role with the native checked state', () => {
		render(<Switch label="Alerts" defaultChecked />);
		const sw = screen.getByRole('switch', { name: 'Alerts' });
		expect(sw.getAttribute('aria-checked')).toBeNull();
		expect((sw as HTMLInputElement).checked).toBe(true);
		fireEvent.click(sw);
		expect((sw as HTMLInputElement).checked).toBe(false);
	});
});

describe('Button', () => {
	it('renders a button by default, with type="button"', () => {
		render(<Button>Save changes</Button>);
		const button = screen.getByRole('button', { name: 'Save changes' });
		expect(button.tagName).toBe('BUTTON');
		expect(button.getAttribute('type')).toBe('button');
	});

	it('renders a link with native link semantics when given href', () => {
		render(
			<Button href="#contact" variant="secondary" size="lg">
				Start a project
			</Button>,
		);
		const link = screen.getByRole('link', { name: 'Start a project' });
		expect(link.tagName).toBe('A');
		expect(link.getAttribute('href')).toBe('#contact');
		expect(link.hasAttribute('type')).toBe(false);
		expect(link.className).toBe('px-btn px-btn--secondary px-btn--lg');
		expect(screen.queryByRole('button')).toBeNull();
	});

	it('passes native attributes through to the button', () => {
		render(
			<Button
				aria-label="Close"
				aria-expanded={false}
				name="intent"
				value="close"
				data-testid="b"
			>
				×
			</Button>,
		);
		const button = screen.getByRole('button', { name: 'Close' });
		expect(button.getAttribute('aria-expanded')).toBe('false');
		expect(button.getAttribute('name')).toBe('intent');
		expect(button.getAttribute('value')).toBe('close');
		expect(button.dataset.testid).toBe('b');
	});

	it('passes native attributes through to the link', () => {
		render(
			<Button href="/docs.pdf" download target="_blank" rel="noopener">
				Download the guide
			</Button>,
		);
		const link = screen.getByRole('link', { name: 'Download the guide' });
		expect(link.hasAttribute('download')).toBe(true);
		expect(link.getAttribute('target')).toBe('_blank');
		expect(link.getAttribute('rel')).toBe('noopener');
	});

	it('merges a consumer className after the design system classes', () => {
		render(<Button className="hero-cta">Go</Button>);
		expect(screen.getByRole('button').className).toBe(
			'px-btn px-btn--primary px-btn--md hero-cta',
		);
	});

	it('forwards a ref to the rendered element', () => {
		const buttonRef = createRef<HTMLButtonElement>();
		const linkRef = createRef<HTMLAnchorElement>();
		render(
			<>
				<Button ref={buttonRef}>Save</Button>
				<Button ref={linkRef} href="/">
					Home
				</Button>
			</>,
		);
		expect(buttonRef.current?.tagName).toBe('BUTTON');
		expect(linkRef.current?.tagName).toBe('A');
		buttonRef.current?.focus();
		expect(document.activeElement).toBe(buttonRef.current);
	});

	it('still calls onClick on a button', () => {
		const onClick = vi.fn();
		render(<Button onClick={onClick}>Save</Button>);
		fireEvent.click(screen.getByRole('button'));
		expect(onClick).toHaveBeenCalledTimes(1);
	});
});
