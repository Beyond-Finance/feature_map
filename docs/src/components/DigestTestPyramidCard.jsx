import React from 'react';
import { Info, Pyramid } from 'lucide-react';
import { ResponsiveContainer, FunnelChart, Funnel, LabelList } from 'recharts';
import { config } from '../utils/config'
import { getTestCoverageLabel, getTestCoverageColor} from '../utils/feature-helpers';

const DigestTestPyramidCard = ({ features }) => {
  const pyramid = Object.entries(features).reduce((acc, [feature_name, feature]) => {
    const {
      integration_count,
      integration_pending,
      regression_count,
      regression_pending,
      unit_count,
      unit_pending,
    } = feature.test_pyramid || {}
    return {
      unit_count: acc.unit_count + (unit_count || 0),
      unit_pending: acc.unit_pending + (unit_pending || 0),
      integration_count: acc.integration_count + (integration_count || 0),
      integration_pending: acc.integration_pending + (integration_pending || 0),
      regression_count: acc.regression_count + (regression_count || 0),
      regression_pending: acc.regression_pending + (regression_pending || 0),
    }
  }, {
    unit_count: 0,
    unit_pending: 0,
    integration_count: 0,
    integration_pending: 0,
    regression_count: 0,
    regression_pending: 0
  })

  const data = [
    {
      "value": Math.log(pyramid.unit_count + pyramid.unit_pending),
      "fill": "#1d4ed8"
    },
    {
      "value": Math.log(pyramid.integration_count + pyramid.integration_pending),
      "fill": "#2563eb"
    },
    {
      "value": Math.log(pyramid.regression_count + pyramid.regression_pending),
      "fill": "#3b82f6"
    },
  ]

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            <Pyramid className="size-5"/>
          </div>
          <span className="flex pl-2">Test Pyramid</span>
        </h3>

        <div className="relative flex-shrink-0 group">
          <Info className="size-4 text-gray-400" />

          <div className="absolute whitespace-wrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2 w-48">
            Test pyramid distribution by category: shows features which are missing
            coverage in a given level of the pyramid, or which have a large number of
            pending tests.
          </div>
        </div>
      </div>

      <div className="flex flex-col items-center gap-6">
        <div className="relative h-48 w-72">
          <ResponsiveContainer width="100%" height="100%">
            <FunnelChart width={730} height={250}>
              <Funnel
                dataKey="value"
                data={data}
                reversed
              >
                <LabelList position="right" fill="#000" stroke="none" dataKey="name" />
              </Funnel>
            </FunnelChart>
          </ResponsiveContainer>
        </div>

        <ul className="flex flex-col flex-1 gap-y-2">
          <li className="flex items-center gap-x-2">
            <div className={`flex-shrink-0 rounded h-6 w-16 size-x-12 flex items-center justify-center bg-blue-500`}>
              <span className="font-semibold text-white text-sm">{pyramid.regression_count}</span>
            </div>
            <p className="text-sm text-gray-500">
              Regression Tests ({pyramid.regression_pending} pending)
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`flex-shrink-0 rounded h-6 w-16 flex items-center justify-center bg-blue-600`}>
              <span className="font-semibold text-white text-sm">{pyramid.integration_count}</span>
            </div>
            <p className="text-sm text-gray-500">
              Integration Tests ({pyramid.integration_pending} pending)
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`flex-shrink-0 rounded h-6 w-16 flex items-center justify-center bg-blue-700`}>
              <span className="font-semibold text-white text-sm">{pyramid.unit_count}</span>
            </div>
            <p className="text-sm text-gray-500">
              Unit Tests ({pyramid.unit_pending} pending)
            </p>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default DigestTestPyramidCard;
