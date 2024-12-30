import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Users } from 'lucide-react';
import {
  calculateHealthScore,
  calculateSize,
  getSizeLabel,
  getFilledPills,
  renderTeams
} from '../utils/feature-helpers';
import {
  healthScoreHexColor,
  healthScoreBackgroundColor,
} from '../utils/health-score';

export default function FeaturesTable({ features }) {
  const [sortConfig, setSortConfig] = useState({
    key: null,
    direction: 'asc'
  });

  const sortedFeatures = React.useMemo(() => {
    const sorted = Object.entries(features).sort((a, b) => {
      const [featureNameA, featureDataA] = a
      const [featureNameB, featureDataB] = b

      if (!sortConfig.key) return 0;

      let aValue, bValue;

      switch(sortConfig.key) {
        case 'team':
          aValue = featureDataA.assignments.teams[0];
          bValue = featureDataB.assignments.teams[0];
          break;
        case 'size':
          aValue = calculateSize(featureDataA);
          bValue = calculateSize(featureDataB);
          break;
        case 'health_score':
          aValue = featureDataA.scores.health.overall;
          bValue = featureDataB.scores.health.overall;
          break;
        case 'test_coverage':
          aValue = featureDataA.scores.testCoverage.score ? featureDataA.scores.testCoverage.score : -1;
          bValue = featureDataB.scores.testCoverage.score ? featureDataB.scores.testCoverage.score : -1;
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

                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <SortHeader title="Feature" sortKey="name" />
                    <SortHeader title="Team" sortKey="team" hideOn="hidden lg:table-cell" />
                    <SortHeader title="Size" sortKey="size" hideOn="hidden md:table-cell" />
                    <SortHeader title="Health Score" sortKey="health_score" hideOn="hidden lg:table-cell" />
                    <SortHeader title="Test Coverage" sortKey="test_coverage" hideOn="hidden md:table-cell" />
                    <th
                      scope="col"
                      className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
                    ></th>

                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {sortedFeatures.map(([name, data]) => {
                    const sizeScore = calculateSize(data);
                    const sizeLabel = getSizeLabel(sizeScore);
                    const healthScore = data.scores.health.overall
                    const coveragePercent = data.scores.testCoverage.score

                    return (
                      <tr key={name}>
                        <td className="w-full max-w-0 py-4 px-4 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none">
                          <div className="flex items-center gap-x-3">
                            <div>
                              <p className="font-medium text-gray-900 text-sm mb-1">{name}</p>
                              <div className="flex items-center gap-1 lg:hidden">
                                <p className="text-sm lg:text-xs font-normal text-gray-500">Team: </p>
                                <div className="flex items-center gap-1">
                                  {data.assignments.teams && data.assignments.teams.map((team, index) => (
                                    <React.Fragment key={team}>
                                      <span className="text-sm lg:text-xs font-normal text-gray-500">{team}</span>
                                      {index < data.assignments.teams.length - 1 && (
                                        <svg viewBox="0 0 2 2" className="size-1 fill-current text-gray-400">
                                          <circle cx="1" cy="1" r="1" />
                                        </svg>
                                      )}
                                    </React.Fragment>
                                  ))}
                                </div>
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          <div className="flex items-center gap-2">
                            <Users className="size-4 text-gray-500" />
                            {renderTeams(data.assignments.teams)}
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 md:table-cell">
                          <div className="flex items-center gap-x-2">
                            <div className="flex gap-1.5 items-center">
                              {[1, 2, 3, 4, 5].map(index => (
                                <div
                                  key={index}
                                  className={`h-5 w-1.5 rounded ${
                                    index <= getFilledPills(sizeScore)
                                      ? 'bg-blue-500'
                                      : 'bg-gray-200'
                                  }`}
                                ></div>
                              ))}
                            </div>
                            <span className="text-xs text-gray-500">
                              {sizeLabel}
                            </span>
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm text-gray-500 lg:table-cell">
                          <div className="flex items-center gap-x-2">
                            <div className={`w-4 h-4 rounded-full flex items-center justify-center ${healthScoreBackgroundColor(healthScore)}`}>
                              <div
                                className="w-2 h-2 rounded-full"
                                style={{ backgroundColor: healthScoreHexColor(healthScore) }}
                              />
                            </div>
                            <span className="text-gray-600">{healthScore.toFixed(0)}%</span>
                          </div>
                        </td>
                        <td className="hidden px-4 py-4 text-sm md:table-cell">
                          <div className="flex items-center gap-x-2">
                            <div className="flex-grow h-2 rounded-full bg-gray-100 overflow-hidden">
                              <div
                                className={`h-full rounded-full ${
                                  !coveragePercent ? 'bg-grey-500' :
                                  coveragePercent >= 99 ? 'bg-green-500' :
                                  coveragePercent >= 95 ? 'bg-yellow-500' :
                                  'bg-red-500'
                                }`}
                                style={{ width: `${coveragePercent}%` }}
                              />
                            </div>
                            <span className="text-sm text-gray-500">
                              {coveragePercent ? `${coveragePercent.toFixed(0)}%` : 'No Data'}
                            </span>
                          </div>
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-500">
                          <div className="flex items-center gap-x-3">
                            <div>
                              <Link
                                to={`/${encodeURIComponent(name)}`}
                                className="flex items-center justify-center flex-shrink-0 font-medium text-gray-900 text-sm mb-1 hover:bg-gray-100 rounded-full h-6 w-6"
                              >
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className="size-5">
                                  <path fillRule="evenodd" d="M8.22 5.22a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L11.94 10 8.22 6.28a.75.75 0 0 1 0-1.06Z" clipRule="evenodd" />
                                </svg>
                              </Link>
                            </div>
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
