import React, { useState } from 'react';

// NOTE: This is just a starting point. If we find this useful,
// we'll want to update these numbers with ones that more closely
// resemble the thresholds commonly seen in a codebase.
function calculateHealthScore(data) {
  const normalized = {
    abc: data.metrics.abc_size / 2000,
    loc: data.metrics.lines_of_code / 3000,
    complexity: data.metrics.cyclomatic_complexity / 300,
    files: data.assignments.files.length / 100
  };

  return (
    normalized.abc * 0.3 +
    normalized.loc * 0.2 +
    normalized.complexity * 0.3 +
    normalized.files * 0.2
  );
}

function getHealthScoreColor(score) {
  if (score < 0.33) return 'text-red-400 bg-red-400/10 ';
  if (score < 0.66) return 'text-yellow-400 bg-yellow-400/10';
  return 'text-green-400 bg-green-400/10';
}

export default function FeatureTable({ features }) {
  const [sortConfig, setSortConfig] = useState({
    key: null,
    direction: 'asc'
  });

  const sortedFeatures = React.useMemo(() => {
    const sorted = Object.entries(features).sort((a, b) => {
      if (!sortConfig.key) return 0;

      let aValue, bValue;

      switch(sortConfig.key) {
        case 'team':
          // Get the first team name from each feature for sorting
          aValue = a[1].assignments.teams[0];
          bValue = b[1].assignments.teams[0];
          break;
        case 'health_score':
          aValue = calculateHealthScore(a[1]);
          bValue = calculateHealthScore(b[1]);
          break;
        case 'test_coverage':
          aValue = a[1].test_coverage.hits / a[1].test_coverage.lines;
          bValue = b[1].test_coverage.hits / b[1].test_coverage.lines;
          break;
        case 'abc_size':
          aValue = a[1].metrics.abc_size;
          bValue = b[1].metrics.abc_size;
          break;
        case 'lines_of_code':
          aValue = a[1].metrics.lines_of_code;
          bValue = b[1].metrics.lines_of_code;
          break;
        case 'complexity':
          aValue = a[1].metrics.cyclomatic_complexity;
          bValue = b[1].metrics.cyclomatic_complexity;
          break;
        default:
          aValue = a[0];
          bValue = b[0];
      }

      if (aValue < bValue) return sortConfig.direction === 'asc' ? -1 : 1;
      if (aValue > bValue) return sortConfig.direction === 'asc' ? 1 : -1;
      return 0;
    });
    return sorted;
  }, [features, sortConfig]);

  const requestSort = (key) => {
    setSortConfig((prevConfig) => ({
      key,
      direction: prevConfig.key === key && prevConfig.direction === 'asc' ? 'desc' : 'asc',
    }));
  };

  const SortHeader = ({ title, sortKey, className = "", hideOn = "" }) => (
    <th
      scope="col"
      className={`px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider ${hideOn} ${className}`}
      onClick={() => requestSort(sortKey)}
    >
      <div className="flex items-center gap-x-2 group cursor-pointer">
        {title}
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="size-4 text-gray-400 group-hover:text-gray-600">
          <path strokeLinecap="round" strokeLinejoin="round" d="M3 7.5 7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5" />
        </svg>
      </div>
    </th>
  );

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mt-8 flow-root">
        <div className="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div className="inline-block min-w-full py-2 align-middle">
            <div className="overflow-hidden shadow-sm border border-gray-200 rounded-lg">
              <table className="min-w-full">
                <colgroup>
                  <col className="lg:w-1/4" />
                  <col className="lg:w-1/5" />
                  <col />
                  <col />
                  <col />
                  <col />
                  <col />
                </colgroup>
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <SortHeader title="Feature" sortKey="name" />
                    <SortHeader title="Team" sortKey="team" hideOn="hidden lg:table-cell" />
                    <SortHeader title="ABC" sortKey="abc_size" hideOn="hidden lg:table-cell" />
                    <SortHeader title="LOC" sortKey="lines_of_code" hideOn="hidden lg:table-cell" />
                    <SortHeader title="Complexity" sortKey="complexity" hideOn="hidden lg:table-cell" />
                    <SortHeader title="Health Score" sortKey="health_score" />
                    <SortHeader title="Test Coverage" sortKey="test_coverage" />
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {sortedFeatures.map(([name, data]) => {
                    const healthScore = calculateHealthScore(data);
                    const colorClass = getHealthScoreColor(healthScore);
                    const coveragePercent = (data.test_coverage.hits / data.test_coverage.lines * 100).toFixed(1);

                    return (
                      <tr key={name}>
                        <td className="w-full max-w-0 py-4 px-4 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none">
                          <div className="flex items-center gap-x-3">
                            <div>
                              <p className="font-medium text-gray-900 text-sm mb-1">{name}</p>
                              <div className="flex items-center gap-1 lg:hidden">
                                <p className="text-sm lg:text-xs font-normal text-gray-500">Team: </p>
                                <div className="flex items-center gap-1">
                                  {data.assignments.teams.map((team, index) => (
                                    <React.Fragment key={team}>
                                      <span className="text-sm lg:text-xs font-normal text-gray-500">{team}</span>
                                      {index < data.assignments.teams.length - 1 && (
                                        <svg viewBox="0 0 2 2" class="size-1 fill-current text-gray-400">
                                          <circle cx="1" cy="1" r="1" />
                                        </svg>
                                      )}
                                    </React.Fragment>
                                  ))}
                                </div>
                              </div>
                              <dl className="font-normal lg:hidden">
                                <dt className="sr-only">ABC Size</dt>
                                <dd className="mt-1 text-gray-500">
                                  ABC: {data.metrics.abc_size.toFixed(1)}
                                </dd>
                                <dt className="sr-only">Lines of Code</dt>
                                <dd className="mt-1 text-gray-500">
                                  LOC: {data.metrics.lines_of_code}
                                </dd>
                                <dt className="sr-only">Complexity</dt>
                                <dd className="mt-1 text-gray-500">
                                  Complexity: {data.metrics.cyclomatic_complexity}
                                </dd>
                              </dl>
                            </div>
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          <div className="flex items-center gap-2">
                            <div className="flex-shrink-0 flex items-center justify-center h-6 w-6 bg-gray-200 rounded-full">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" class="size-4 text-gray-500">
                                <path d="M8 8a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5ZM3.156 11.763c.16-.629.44-1.21.813-1.72a2.5 2.5 0 0 0-2.725 1.377c-.136.287.102.58.418.58h1.449c.01-.077.025-.156.045-.237ZM12.847 11.763c.02.08.036.16.046.237h1.446c.316 0 .554-.293.417-.579a2.5 2.5 0 0 0-2.722-1.378c.374.51.653 1.09.813 1.72ZM14 7.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0ZM3.5 9a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3ZM5 13c-.552 0-1.013-.455-.876-.99a4.002 4.002 0 0 1 7.753 0c.136.535-.324.99-.877.99H5Z" />
                              </svg>
                            </div>
                            {data.assignments.teams.length > 1 ? (
                              <p>{data.assignments.teams[0]} + {data.assignments.teams.length - 1}</p>
                            ) : (
                              data.assignments.teams[0]
                            )}
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          {data.metrics.abc_size.toFixed(1)}
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          {data.metrics.lines_of_code}
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          {data.metrics.cyclomatic_complexity}
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-500">
                          <div className="flex items-center gap-x-3">
                            <div className={`flex-none rounded-full p-1 ${colorClass}`}>
                              <div className="h-1.5 w-1.5 rounded-full bg-current" />
                            </div>
                            <span>{(healthScore * 100).toFixed(0)}%</span>
                          </div>
                        </td>
                        <td className="table-cell px-4 py-4 text-sm">
                          <div className="flex items-center gap-x-2">
                            <div className="flex-grow h-2 rounded-full bg-gray-100 overflow-hidden">
                              <div
                                className={`h-full rounded-full ${
                                  coveragePercent >= 95 ? 'bg-green-500' :
                                  coveragePercent >= 75 ? 'bg-yellow-500' :
                                  'bg-red-500'
                                }`}
                                style={{ width: `${coveragePercent}%` }}
                              />
                            </div>
                            <span className="text-sm text-gray-500">
                              {coveragePercent}%
                            </span>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
