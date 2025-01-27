import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Info, Pyramid, Users } from 'lucide-react';
import { Listbox, ListboxButton, ListboxOption, ListboxOptions } from '@headlessui/react'
import { ResponsiveContainer, FunnelChart, Funnel, LabelList } from 'recharts';
import { config } from '../utils/config'
import { getTestCoverageLabel, getTestCoverageColor} from '../utils/feature-helpers';
import { Dropdown, Switcher } from './ui'
import {
  getFeatureSizeLabel,
  getFilledPills,
  renderTeams,
} from '../utils/feature-helpers';

const TableHeader = ({ title }) => (
  <th
    scope="col"
    className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
  >
    <div className="flex items-center gap-x-2">
      {title}
    </div>
  </th>
);

const highlightFeatures = ({ features, metric, sortDirection = 'ASC' }) => {
  return Object
    .entries(features)
    .sort(([featureNameA, featureA], [featureNameB, featureB]) => {
      const metricA = featureA.test_pyramid ? featureA.test_pyramid[metric] || 0 : 0
      const metricB = featureB.test_pyramid ? featureB.test_pyramid[metric] || 0 : 0

      // If the metric is the same, return the large feature
      if (metricA === metricB) {
        return featureB.metrics.featureSize.score - featureA.metrics.featureSize.score
      }

      if (sortDirection === 'ASC') return metricA - metricB
      return metricB - metricA
    })
    .slice(0, 5)
    .map(([featureName, feature]) => ({
      featureName,
      score: feature.test_pyramid ? feature.test_pyramid[metric] || 0 : 0,
      feature,
    }))
}

const testTypes = ['Regression', 'Integration', 'Unit']
const viewTypes = ['Missing', 'Pending']
const metrics = {
  Pending: {
    Unit: 'unit_pending',
    Integration: 'integration_pending',
    Regression: 'regression_pending'
  },
  Missing: {
    Unit: 'unit_count',
    Integration: 'integration_count',
    Regression: 'regression_count'
  }
}

const titles = {
  Pending: {
    Unit: 'Top 5 features with pending unit tests',
    Integration: 'Top 5 features with pending integration tests',
    Regression: 'Top 5 features with pending regression tests'
  },
  Missing: {
    Unit: 'Bottom 5 features missing unit test coverage',
    Integration: 'Bottom 5 features missing integration tests',
    Regression: 'Bottom 5 features missing regression tests'
  }
}

const DigestTestPyramidDetails = ({ features }) => {
  const [viewType, setViewType] = useState(viewTypes[0])
  const [testType, setTestType] = useState(testTypes[0])
  const [pyramidDetails, setPyramidDetails] = useState(
    highlightFeatures({
      features,
      metric: metrics[viewType][testType],
      sortDirection: viewType === 'Missing' ? 'ASC' : ''
    })
  )

  useEffect(() => {
    setPyramidDetails(
      highlightFeatures({
        features,
        metric: metrics[viewType][testType],
        sortDirection: viewType === 'Missing' ? 'ASC' : ''
      })
    )
  }, [features, viewType, testType])

  return <>
    <div className="flex items-center justify-between px-4 py-6 bg-gray-50 rounded-md">
      <h3 className="flex items-center text-xs font-semibold text-gray-800 uppercase h-8">
        {titles[viewType][testType]}
      </h3>
      <div className="flex h-8">
        <Switcher items={viewTypes} selectedItem={viewType} onItemSelect={setViewType} size="xs" />
        <span className="mx-2" />
        <Dropdown items={testTypes} selectedItem={testType} onItemSelect={setTestType} size="xs" />
      </div>
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
                <TableHeader title={viewType === 'Missing' ? `${testType} Test Count` : 'Pending Test Count'} />
                <th
                  scope="col"
                  className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider"
                ></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 bg-white">
              {pyramidDetails.map(({ featureName, feature, score }) => {
                const sizeScore = feature.metrics.featureSize.percentOfMax
                const sizeLabel = getFeatureSizeLabel(sizeScore);

                return (
                  <tr key={featureName}>
                    <td className="w-full max-w-0 py-4 px-4 text-sm font-medium text-gray-900 sm:w-auto sm:max-w-none">
                      <div className="">
                        {featureName}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-sm text-gray-500">
                      <div className="flex items-center gap-2">
                        <Users className="size-4 text-gray-500" />
                        {renderTeams(feature.assignments.teams)}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-sm text-gray-500">
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
                        <span className="text-xs text-gray-500 uppercase">
                          {sizeLabel}
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-4 text-sm">
                      <div className="flex items-center gap-x-2">
                        {score}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-sm text-gray-500">
                      <div className="flex items-center gap-x-3">
                        <div>
                          <Link
                            to={`/${encodeURIComponent(featureName)}`}
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
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </>;
};

export default DigestTestPyramidDetails;
