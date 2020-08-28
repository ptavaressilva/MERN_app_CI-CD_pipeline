import React from 'react';
import {
    render
} from '@testing-library/react';
import App from './App';


test('renders client says phrase', () => {
    const {
        getByText
    } = render( < App / > );
    const linkElement = getByText(/Hello server/i);
    expect(linkElement).toBeInTheDocument();
});