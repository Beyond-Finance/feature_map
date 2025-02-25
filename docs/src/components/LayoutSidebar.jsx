import { Link, useLocation } from 'react-router-dom'
import { ClipboardList, Component, ExternalLink, Home } from 'lucide-react';
import { config } from '../utils/config';

const navigation = [
  { name: 'Dashboard', pathname: '', icon: Home },
  { name: 'Digest', pathname: 'Digest', icon: ClipboardList },
]

function classNames(...classes) {
  return classes.filter(Boolean).join(' ')
}

export default function LayoutSidebar() {
  const location = useLocation();
  const { linked_sites: linkedSites, title } = config.project.documentation_site

  return (
    <>
      <div className="flex h-16 shrink-0 items-center">
        <Link to="/">
          Feature Documentation
        </Link>
      </div>
      <nav className="flex flex-1 flex-col">
        <ul role="list" className="flex flex-1 flex-col gap-y-7">
          <li>
            <div className="text-xs/6 font-semibold text-gray-400">{title}</div>
            <ul role="list" className="-mx-2 mt-2 space-y-2">
              {navigation.map(item => (
                <li key={item.name}>
                  <Link
                    to={item.pathname}
                    className={classNames(
                      location.pathname === `/${item.pathname}`
                        ? 'text-blue-600'
                        : 'text-gray-700 hover:text-blue-600',
                      'group flex gap-x-3 rounded-md px-2 text-sm/6 font-semibold items-center',
                    )}
                  >
                    <item.icon
                      aria-hidden="true"
                      className={classNames(
                        'text-gray-400 group-hover:text-blue-600',
                        'size-5 shrink-0',
                      )}
                    />
                    {item.name}
                  </Link>
                </li>
              ))}
            </ul>
          </li>
          {linkedSites && linkedSites.length > 0 && (
            <li>
              <div className="text-xs/6 font-semibold text-gray-400">Linked Feature Documentation</div>
              <ul role="list" className="-mx-2 mt-2 space-y-2">
                {linkedSites.map((site) => (
                  <li key={site.name}>
                    <a
                      href={site.url}
                      target="_blank"
                      className={classNames(
                        'text-gray-700 hover:text-blue-600',
                        'group flex gap-x-3 rounded-md px-2 text-sm/6 font-semibold items-center',
                      )}
                    >
                      <ExternalLink
                        aria-hidden="true"
                        className={classNames(
                          'text-gray-400 group-hover:text-blue-600',
                          'size-5 shrink-0',
                        )}
                      />
                      {site.name}

                    </a>
                  </li>
                ))}
              </ul>
            </li>
          )}
        </ul>
      </nav>
    </>
  )
}
