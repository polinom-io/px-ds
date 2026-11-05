import { act, cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { Alert, Field, Modal, Progress, Tabs } from '../src/index.js';

afterEach(cleanup);

describe('Tabs (WAI-ARIA tabs pattern)', () => {
  const tabs = [{ label: 'One', content: 'Panel one' }, { label: 'Two', content: 'Panel two' }, { label: 'Three', content: 'Panel three' }];

  it('has one tab stop and shows only the selected panel', () => {
    render(<Tabs label="Example" tabs={tabs} />);
    const all = screen.getAllByRole('tab');
    expect(all.map((t) => t.tabIndex)).toEqual([0, -1, -1]);
    expect(screen.getByRole('tabpanel')).toHaveProperty('textContent', 'Panel one');
  });

  it('moves with Right, Left, Home and End, and wraps around', () => {
    render(<Tabs label="Example" tabs={tabs} />);
    const list = screen.getByRole('tablist');
    const selected = () => screen.getAllByRole('tab').findIndex((t) => t.getAttribute('aria-selected') === 'true');
    fireEvent.keyDown(list, { key: 'ArrowRight' }); expect(selected()).toBe(1);
    fireEvent.keyDown(list, { key: 'End' }); expect(selected()).toBe(2);
    fireEvent.keyDown(list, { key: 'ArrowRight' }); expect(selected()).toBe(0);
    fireEvent.keyDown(list, { key: 'ArrowLeft' }); expect(selected()).toBe(2);
    fireEvent.keyDown(list, { key: 'Home' }); expect(selected()).toBe(0);
    expect(document.activeElement).toBe(screen.getAllByRole('tab')[0]);
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
    render(<Field label="Email" type="email" helper="Work address" error="Enter a valid email." />);
    const input = screen.getByLabelText('Email');
    expect(input.getAttribute('aria-invalid')).toBe('true');
    const ids = input.getAttribute('aria-describedby')!.split(' ');
    expect(ids.map((id) => document.getElementById(id)?.textContent)).toEqual(['Work address', 'Enter a valid email.']);
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
    expect(screen.getByRole('progressbar').getAttribute('aria-valuenow')).toBe('100');
    expect(screen.getByText('100%')).toBeTruthy();
  });
});

describe('Modal', () => {
  beforeAll(() => {
    // jsdom has <dialog> but not showModal()/close(); stand in for the browser.
    HTMLDialogElement.prototype.showModal = vi.fn(function (this: HTMLDialogElement) { this.setAttribute('open', ''); });
    HTMLDialogElement.prototype.close = vi.fn(function (this: HTMLDialogElement) { this.removeAttribute('open'); this.dispatchEvent(new Event('close')); });
  });

  it('opens with showModal() and calls onClose when closed', async () => {
    const onClose = vi.fn();
    const { rerender } = render(<Modal open={false} title="Delete this project?" onClose={onClose}>Body</Modal>);
    const dialog = document.querySelector('dialog')!;
    expect(dialog.open).toBe(false);
    await act(async () => { rerender(<Modal open title="Delete this project?" onClose={onClose}>Body</Modal>); });
    expect(dialog.open).toBe(true);
    expect(dialog.getAttribute('aria-labelledby')).toBe(screen.getByText('Delete this project?').id);
    fireEvent.click(screen.getByLabelText('Close'));
    expect(dialog.open).toBe(false);
    expect(onClose).toHaveBeenCalledTimes(1);
  });
});
