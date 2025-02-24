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
  const maybeFeaturePath = decodeURI(location.pathname).substring(1)
  const onFeatureShowPage = Object.keys(config.features).includes(maybeFeaturePath)

  return (
    <>
      <div className="flex h-16 shrink-0 items-center">
        FeatureMap - {title}
      </div>
      <nav className="flex flex-1 flex-col">
        <ul role="list" className="flex flex-1 flex-col gap-y-7">
          <li>
            <ul role="list" className="-mx-2 space-y-1">
              <li>
                <Link
                  to='/'
                  className={classNames(
                    location.pathname === '/'
                      ? 'text-indigo-600'
                      : 'text-gray-700 hover:text-indigo-600',
                    'group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold',
                  )}
                >
                  <Home
                    aria-hidden="true"
                    className={classNames(
                      location.pathname === '/' ? 'text-indigo-600' : 'text-gray-400 group-hover:text-indigo-600',
                      'size-6 shrink-0',
                    )}
                  />
                  <div class="flex flex-col">
                    Dashboard
                    {false && (
                      <span
                        className={classNames(
                          'text-indigo-600 group flex rounded-md text-xs font-semibold',
                        )}
                      >

                        - {maybeFeaturePath}
                      </span>
                    )}
                  </div>
                </Link>
              </li>
              <li>
                <Link
                  to='Digest'
                  className={classNames(
                    location.pathname === '/Digest'
                      ? 'text-indigo-600'
                      : 'text-gray-700 hover:text-indigo-600',
                    'group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold',
                  )}
                >
                  <ClipboardList
                    aria-hidden="true"
                    className={classNames(
                      location.pathname === '/Digest' ? 'text-indigo-600' : 'text-gray-400 group-hover:text-indigo-600',
                      'size-6 shrink-0',
                    )}
                  />
                  Digest
                </Link>
              </li>
            </ul>
          </li>
          {linkedSites && linkedSites.length > 0 && (
            <li>
              <div className="text-xs/6 font-semibold text-gray-400">Other Documentation Sites</div>
              <ul role="list" className="-mx-2 mt-2 space-y-1">
                {linkedSites.map((site) => (
                  <li key={site.name}>
                    <a
                      href={site.url}
                      target="_blank"
                      className={classNames(
                        site.current
                          ? 'text-indigo-600'
                          : 'text-gray-700 hover:text-indigo-600',
                        'group flex gap-x-3 rounded-md px-2 text-sm/6 font-semibold items-center',
                      )}
                    >
                      {site.name}
                      <ExternalLink
                        aria-hidden="true"
                        className={classNames(
                          location.pathname === `/${site.pathname}` ? 'text-indigo-600' : 'text-gray-400 group-hover:text-indigo-600',
                          'size-4 shrink-0',
                        )}
                      />
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
