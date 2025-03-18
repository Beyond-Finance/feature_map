import React, { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { Users } from 'lucide-react';
import { Dropdown } from '../components/ui';
import DigestHealthScoreCard from '../components/DigestHealthScoreCard';
import DigestTestCoverageCard from '../components/DigestTestCoverageCard';
import DigestTestPyramidCard from '../components/DigestTestPyramidCard';
import DigestTestPyramidDetails from '../components/DigestTestPyramidDetails';
import {
  getFeatureSizeLabel,
  getFilledPills,
  renderTeams,
  getTestCoverageColor,
} from '../utils/feature-helpers';
import { healthScoreBackgroundColor, getHealthScoreColor } from '../utils/health-score';

export default function Digest({ features }) {
  const [selectedTeam, setSelectedTeam] = useState('All Teams');

  const teams = useMemo(() => {
    const teamSet = new Set();
    teamSet.add('All Teams');

    Object.values(features).forEach((feature) => {
      if (feature.assignments?.teams) {
        feature.assignments.teams.forEach((team) => teamSet.add(team));
      }
    });

    return Array.from(teamSet);
  }, [features]);

  const filteredFeatures = useMemo(() => {
    if (selectedTeam === 'All Teams') return features;

    return Object.fromEntries(
      Object.entries(features).filter(([_, data]) =>
        data.assignments?.teams?.includes(selectedTeam)
      )
    );
  }, [features, selectedTeam]);

  const healthScores = useMemo(
    () =>
      Object.entries(filteredFeatures)
        .map(([name, data]) => ({
          name,
          data: data || 0,
          health: data.additional_metrics.health.overall || 0,
        }))
        .sort((a, b) => a.health - b.health)
        .slice(0, 5),
    [filteredFeatures]
  );

  const testCoverageScores = useMemo(
    () =>
      Object.entries(filteredFeatures)
        .map(([name, data]) => ({
          name,
          data: data || 0,
          score: data.additional_metrics.test_coverage.score || 0,
        }))
        .sort((a, b) => a.score - b.score)
        .slice(0, 5),
    [filteredFeatures]
  );

  const TableHeader = ({ title }) => (
    <th
      scope="col"
      className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
    >
      <div className="flex items-center gap-x-2">{title}</div>
    </th>
  );

  return (
    <div className="h-screen max-w-7xl mx-auto flex flex-col gap-8 p-4 md:p-8">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Digest</h1>
        <Dropdown items={teams} selectedItem={selectedTeam} onItemSelect={setSelectedTeam} />
      </div>

      <div className="flow-root">
        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-1 border border-gray-200 shadow-xs bg-white rounded-lg h-full">
            <div className="px-4 py-6 h-fit">
              <DigestHealthScoreCard features={filteredFeatures} />
            </div>
          </div>

          <div className="col-span-2 h-full shadow-xs border border-gray-200 rounded-lg bg-white">
            <div className="flex items-center justify-between px-4 py-6 bg-gray-50 rounded-md">
              <h3 className="flex items-center text-xs font-semibold text-gray-800 uppercase h-8">
                Bottom 5 Features by Health Score
              </h3>
            </div>

            <div className="flow-root">
              <div className="min-w-full align-middle">
                <div className="overflow-hidden rounded-md">
                  <table className="min-w-full">
                    <thead className="bg-gray-50 border-b border-gray-200">
                      <tr>
                        <TableHeader title="Feature" />
                        <TableHeader title="Team" />
                        <TableHeader title="Size" />
                        <TableHeader title="Health Score" />
                        <th
                          scope="col"
                          className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
                        ></th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 bg-white">
                      {healthScores.map((feature) => {
                        const sizeScore =
                          feature.data.additional_metrics.feature_size.percent_of_max;
                        const sizeLabel = getFeatureSizeLabel(sizeScore);
                        const healthScore = feature.data.additional_metrics.health.score || 0;

                        return (
                          <tr key={feature.name}>
                            <td className="w-full max-w-0 py-4 px-4 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none">
                              <div className="">{feature.name}</div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-2">
                                <Users className="size-4 text-gray-500" />
                                {renderTeams(feature.data.assignments.teams)}
                              </div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-x-2">
                                <div className="flex gap-1.5 items-center">
                                  {[1, 2, 3, 4, 5].map((index) => (
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
                                <span className="text-xs text-gray-500 uppercase">{sizeLabel}</span>
                              </div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-x-2">
                                <div
                                  className={`w-4 h-4 rounded-full flex items-center justify-center ${healthScoreBackgroundColor(healthScore)}`}
                                >
                                  <div
                                    className={`w-2 h-2 rounded-full ${getHealthScoreColor(healthScore).class}`}
                                  />
                                </div>
                                <span className="text-gray-600">{healthScore.toFixed(0)}%</span>
                              </div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-x-3">
                                <div>
                                  <Link
                                    to={`/${encodeURIComponent(feature.name)}`}
                                    className="flex items-center justify-center shrink-0 font-medium text-gray-900 text-sm mb-1 hover:bg-gray-100 rounded-full h-6 w-6"
                                  >
                                    <svg
                                      xmlns="http://www.w3.org/2000/svg"
                                      viewBox="0 0 20 20"
                                      fill="currentColor"
                                      className="size-5"
                                    >
                                      <path
                                        fillRule="evenodd"
                                        d="M8.22 5.22a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L11.94 10 8.22 6.28a.75.75 0 0 1 0-1.06Z"
                                        clipRule="evenodd"
                                      />
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
      </div>

      <div className="flow-root">
        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-1 border border-gray-200 shadow-xs bg-white rounded-lg">
            <div className="px-4 py-6">
              <DigestTestCoverageCard features={filteredFeatures} />
            </div>
          </div>

          <div className="col-span-2 h-full shadow-xs border border-gray-200 rounded-lg bg-white">
            <div className="flex items-center justify-between px-4 py-6 bg-gray-50 rounded-md">
              <h3 className="flex items-center text-xs font-semibold text-gray-800 uppercase h-8">
                Bottom 5 Features by Test Coverage
              </h3>
            </div>

            <div className="flow-root">
              <div className="min-w-full align-middle">
                <div className="overflow-hidden rounded-md">
                  <table className="min-w-full">
                    <thead className="bg-gray-50 border-b border-gray-200">
                      <tr>
                        <TableHeader title="Feature" />
                        <TableHeader title="Team" />
                        <TableHeader title="Size" />
                        <TableHeader title="Test Coverage" />
                        <th
                          scope="col"
                          className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
                        ></th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 bg-white">
                      {testCoverageScores.map((feature) => {
                        const sizeScore =
                          feature.data.additional_metrics.feature_size.percent_of_max;
                        const sizeLabel = getFeatureSizeLabel(sizeScore);
                        const coveragePercent =
                          feature.data.additional_metrics.test_coverage.score || 0;

                        return (
                          <tr key={feature.name}>
                            <td className="w-full max-w-0 py-4 px-4 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none">
                              <div className="">{feature.name}</div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-2">
                                <Users className="size-4 text-gray-500" />
                                {renderTeams(feature.data.assignments.teams)}
                              </div>
                            </td>
                            <td className="px-4 py-4 text-sm text-gray-500">
                              <div className="flex items-center gap-x-2">
                                <div className="flex gap-1.5 items-center">
                                  {[1, 2, 3, 4, 5].map((index) => (
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
                                <span className="text-xs text-gray-500 uppercase">{sizeLabel}</span>
                              </div>
                            </td>
                            <td className="px-4 py-4 text-sm">
                              <div className="flex items-center gap-x-2">
                                <div className="grow h-2 rounded-full bg-gray-100 overflow-hidden">
                                  <div
                                    className={`h-full rounded-full ${getTestCoverageColor(coveragePercent).class}`}
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
                                    to={`/${encodeURIComponent(feature.name)}`}
                                    className="flex items-center justify-center shrink-0 font-medium text-gray-900 text-sm mb-1 hover:bg-gray-100 rounded-full h-6 w-6"
                                  >
                                    <svg
                                      xmlns="http://www.w3.org/2000/svg"
                                      viewBox="0 0 20 20"
                                      fill="currentColor"
                                      className="size-5"
                                    >
                                      <path
                                        fillRule="evenodd"
                                        d="M8.22 5.22a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L11.94 10 8.22 6.28a.75.75 0 0 1 0-1.06Z"
                                        clipRule="evenodd"
                                      />
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
      </div>

      <div className="flow-root">
        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-1 border border-gray-200 shadow-xs bg-white rounded-lg">
            <div className="px-4 py-6">
              <DigestTestPyramidCard features={filteredFeatures} />
            </div>
          </div>

          <div className="col-span-2 h-full shadow-xs border border-gray-200 rounded-lg bg-white">
            <DigestTestPyramidDetails features={filteredFeatures} />
          </div>
        </div>
      </div>
    </div>
  );
}
