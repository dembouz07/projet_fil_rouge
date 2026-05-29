import React from 'react';

export const NavLink = ({ to, children, className, end }) => {
  const isActive = to === '/';
  const computedClassName = typeof className === 'function' 
    ? className({ isActive }) 
    : className;
  return (
    <a href={to} className={computedClassName}>
      {children}
    </a>
  );
};

export const BrowserRouter = ({ children }) => <div>{children}</div>;
export const MemoryRouter = ({ children }) => <div>{children}</div>;
export const Route = ({ children }) => <div>{children}</div>;
export const Routes = ({ children }) => <div>{children}</div>;
