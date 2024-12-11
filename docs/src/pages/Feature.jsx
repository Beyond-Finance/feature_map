// src/pages/Feature.jsx
import { useParams, Link } from 'react-router-dom';

export default function Feature({ features }) {
  // Get the feature name from the URL parameters
  const { name } = useParams();
  // Look up the feature data
  const feature = features[name];

  if (!feature) {
    return (
      <div className="max-w-8xl mx-auto p-4 md:p-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h1 className="text-xl font-bold text-red-600">Feature Not Found</h1>
          <p className="mt-2">Could not find feature: {name}</p>
          <Link to="/" className="text-indigo-600 hover:text-indigo-800 mt-4 inline-block">
            ← Back to Features
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-8xl mx-auto p-4 md:p-8">
      <div className="bg-white rounded-lg shadow p-6">
        <Link to="/" className="text-indigo-600 hover:text-indigo-800 mb-4 inline-block">
          ← Back to Features
        </Link>

        <h1 className="text-2xl font-bold mt-4">{name}</h1>

        <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-gray-50 p-4 rounded-lg">
            <h2 className="font-semibold text-gray-900">Metrics</h2>
            <dl className="mt-2 space-y-1">
              <div className="flex justify-between">
                <dt className="text-gray-600">ABC Size:</dt>
                <dd className="font-medium">{feature.metrics.abc_size.toFixed(1)}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-gray-600">Lines of Code:</dt>
                <dd className="font-medium">{feature.metrics.lines_of_code}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-gray-600">Complexity:</dt>
                <dd className="font-medium">{feature.metrics.cyclomatic_complexity}</dd>
              </div>
            </dl>
          </div>

          <div className="bg-gray-50 p-4 rounded-lg">
            <h2 className="font-semibold text-gray-900">Teams</h2>
            <ul className="mt-2 space-y-1">
              {feature.assignments.teams.map(team => (
                <li key={team} className="text-gray-600">{team}</li>
              ))}
            </ul>
          </div>

          <div className="bg-gray-50 p-4 rounded-lg">
            <h2 className="font-semibold text-gray-900">Test Coverage</h2>
            <div className="mt-2">
              <div className="flex items-center gap-x-2">
                <div className="flex-grow h-2 rounded-full bg-gray-200 overflow-hidden">
                  <div
                    className="h-full rounded-full bg-green-500"
                    style={{
                      width: `${(feature.test_coverage.hits / feature.test_coverage.lines * 100).toFixed(1)}%`
                    }}
                  />
                </div>
                <span className="text-sm text-gray-600">
                  {(feature.test_coverage.hits / feature.test_coverage.lines * 100).toFixed(1)}%
                </span>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8">
          <h2 className="font-semibold text-gray-900 mb-4">Files</h2>
          <ul className="space-y-2">
            {feature.assignments.files.map(file => (
              <li key={file} className="text-sm text-gray-600">{file}</li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}
