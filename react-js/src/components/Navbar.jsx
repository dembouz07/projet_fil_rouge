import { NavLink } from 'react-router-dom'

export default function Navbar() {
    return (
        <nav className="bg-gray-900 shadow-md border-b-2 border-gray-700 text-white fixed w-full top-0 z-50 h-16 flex items-center">
            <div className="max-w-6xl mx-auto px-6 flex items-center justify-between w-full">

                {/* Logo */}
                <NavLink to="/" className="flex items-center">
                    <img
                        src="/assets/logo.png"
                        alt="Logo"
                        className="h-20 inline-block"
                        onError={e => { e.target.style.display = 'none' }}
                    />
                </NavLink>

                {/* Liens nav */}
                <ul className="flex gap-1 list-none m-0 p-0">
                    {[
                        { to: '/',        label: 'Accueil', icon: 'fa-house',    end: true },
                        { to: '/projets', label: 'Projets', icon: 'fa-briefcase' },
                        { to: '/contact', label: 'Contact', icon: 'fa-envelope'  },
                    ].map(({ to, label, icon, end }) => (
                        <li key={to}>
                            <NavLink
                                to={to}
                                end={end}
                                className={({ isActive }) =>
                                    `flex items-center gap-1.5 px-4 py-2 rounded-lg text-base font-semibold transition-all duration-200 no-underline
                  ${isActive
                                        ? 'text-white bg-white/10'
                                        : 'text-gray-300 hover:text-white hover:bg-white/10'}`
                                }
                            >
                                <i className={`fas ${icon} mr-1`} /> {label}
                            </NavLink>
                        </li>
                    ))}
                </ul>
            </div>
        </nav>
    )
}