import { render, screen } from '@testing-library/react';
import React from 'react';

// Utilise le mock manuel de react-router-dom
jest.mock('react-router-dom');

import Navbar from '../Navbar';

describe('Navbar Component', () => {
  it('devrait afficher le logo', () => {
    render(<Navbar />);
    const logo = screen.getByAltText('Logo');
    expect(logo).toBeInTheDocument();
    expect(logo).toHaveAttribute('src', '/assets/logo.png');
  });

  it('devrait afficher les liens de navigation', () => {
    render(<Navbar />);
    expect(screen.getByText('Accueil')).toBeInTheDocument();
    expect(screen.getByText('Projets')).toBeInTheDocument();
    expect(screen.getByText('Contact')).toBeInTheDocument();
  });

  it('devrait avoir des liens fonctionnels vers les bonnes routes', () => {
    render(<Navbar />);
    
    const homeLink = screen.getByRole('link', { name: /accueil/i });
    const projectsLink = screen.getByRole('link', { name: /projets/i });
    const contactLink = screen.getByRole('link', { name: /contact/i });
    
    expect(homeLink).toHaveAttribute('href', '/');
    expect(projectsLink).toHaveAttribute('href', '/projets');
    expect(contactLink).toHaveAttribute('href', '/contact');
  });

  it('devrait afficher les icônes Font Awesome', () => {
    render(<Navbar />);
    
    const icons = document.querySelectorAll('.fas');
    expect(icons.length).toBeGreaterThan(0);
  });

  it('devrait avoir une classe de navigation fixe', () => {
    const { container } = render(<Navbar />);
    const nav = container.querySelector('nav');
    
    expect(nav).toHaveClass('fixed');
    expect(nav).toHaveClass('w-full');
    expect(nav).toHaveClass('top-0');
  });
});
