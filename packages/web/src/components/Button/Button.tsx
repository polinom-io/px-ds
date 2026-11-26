import {
	type AnchorHTMLAttributes,
	type ButtonHTMLAttributes,
	type ForwardedRef,
	forwardRef,
	type ReactNode,
	type Ref,
} from 'react';
import { cx } from '../../internal/shared.js';

interface ButtonStyleProps {
	/** primary: the one main action per view · secondary: outlined · ghost: no fill until hover · danger: destructive. */
	variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
	/** Heights follow size-control-sm | md | lg (32 / 40 / 48px). */
	size?: 'sm' | 'md' | 'lg';
	children: ReactNode;
}

/** An action: renders a native `<button>`. `onClick` only works inside a React island; a function cannot cross an Astro island boundary. */
export interface ButtonAsButtonProps
	extends ButtonStyleProps,
		Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
	href?: undefined;
	ref?: Ref<HTMLButtonElement>;
}

/** Navigation: renders a native `<a>` with the button's look. Links have no disabled state. */
export interface ButtonAsLinkProps
	extends ButtonStyleProps,
		Omit<
			AnchorHTMLAttributes<HTMLAnchorElement>,
			'children' | 'href' | 'type'
		> {
	href: string;
	type?: undefined;
	ref?: Ref<HTMLAnchorElement>;
}

export type ButtonProps = ButtonAsButtonProps | ButtonAsLinkProps;

function ButtonImpl(
	props: ButtonAsButtonProps | ButtonAsLinkProps,
	ref: ForwardedRef<HTMLButtonElement | HTMLAnchorElement>,
) {
	const { variant = 'primary', size = 'md', className, children } = props;
	const classes = cx(
		'px-btn',
		`px-btn--${variant}`,
		`px-btn--${size}`,
		className,
	);

	if (props.href !== undefined) {
		const {
			variant: _variant,
			size: _size,
			className: _className,
			children: _children,
			...anchorProps
		} = props;
		return (
			<a
				{...anchorProps}
				ref={ref as ForwardedRef<HTMLAnchorElement>}
				className={classes}
			>
				{children}
			</a>
		);
	}

	const {
		variant: _variant,
		size: _size,
		className: _className,
		children: _children,
		type = 'button',
		href: _href,
		...buttonProps
	} = props;
	return (
		<button
			{...buttonProps}
			ref={ref as ForwardedRef<HTMLButtonElement>}
			type={type}
			className={classes}
		>
			{children}
		</button>
	);
}

/**
 * Button (ACT-01). An action renders `<button>`; navigation (`href`) renders `<a>` with the same look.
 * No client JavaScript needed unless `onClick` is used inside a React island.
 */
export const Button = forwardRef(ButtonImpl) as {
	(props: ButtonAsButtonProps): ReactNode;
	(props: ButtonAsLinkProps): ReactNode;
	displayName?: string;
};
Button.displayName = 'Button';
