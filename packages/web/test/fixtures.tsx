import type { ReactElement } from 'react';
import { Alert, Avatar, Badge, Button, Card, Checkbox, CurveDivider, Field, Modal, Progress, Stat, Switch, Table, Tabs } from '../src/index.js';

/** One representative render of every component, with props an .astro page could pass (no functions). */
export const fixtures: Record<string, ReactElement> = {
  Alert: <Alert tone="warning" title="Spanish copy needs review">First-pass translation, not yet reviewed.</Alert>,
  Avatar: <Avatar initials="ME" name="Mario Espinoza" tone="secondary" size="lg" />,
  Badge: <Badge tone="tertiary" variant="solid">Data</Badge>,
  Button: <Button variant="primary" size="lg">Start a project</Button>,
  Card: <Card tone="quaternary" exponent="x³" title="Strategy">The highest-degree term.</Card>,
  Checkbox: <Checkbox label="I agree to the privacy policy" name="consent" />,
  CurveDivider: <CurveDivider ariaLabel="Growth curve, rising left to right" />,
  Field: <Field label="Work email" type="email" name="email" required helper="We reply within one business day." error="Enter a valid email address." />,
  FieldSelect: <Field label="Topic" type="select" name="topic" options={['Product', 'Partnership']} />,
  Modal: <Modal open={false} title="Delete this project?">This removes the project and its files.</Modal>,
  Progress: <Progress label="Design" value={60} tone="secondary" />,
  Stat: <Stat value="4" label="terms in every engagement" />,
  Switch: <Switch label="Email updates" name="updates" defaultChecked />,
  Table: <Table caption="How the terms are weighted" columns={['Term', 'Degree']} rows={[['Strategy', 'x³'], ['Delivery', 'x⁰']]} />,
  Tabs: <Tabs label="Engagement" tabs={[{ label: 'Overview', content: 'What we do' }, { label: 'Process', content: 'How we work' }, { label: 'Pricing', content: 'What it costs' }]} />,
};
