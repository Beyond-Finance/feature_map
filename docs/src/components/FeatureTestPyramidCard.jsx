import React from 'react';
import { Triangle } from 'lucide-react';
import { FunnelChart, Funnel, LabelList } from 'recharts';

const FeatureTestPyramidCard = ({ feature }) => {
  const {
    integration_count = 0,
    integration_pending = 0,
    regression_count = 0,
    regression_pending = 0,
    unit_count = 0,
    unit_pending = 0,
  } = feature?.test_pyramid || {};

  const testTypes = [
    {
      type: 'Unit Tests',
      count: unit_count,
      pending: unit_pending,
      color: 'blue-700',
      fill: '#1d4ed8', // Tailwind blue-700 equivalent hex
    },
    {
      type: 'Integration Tests',
      count: integration_count,
      pending: integration_pending,
      color: 'blue-500',
      fill: '#3b82f6', // Tailwind blue-500 equivalent hex
    },
    {
      type: 'Regression Tests',
      count: regression_count,
      pending: regression_pending,
      color: 'blue-300',
      fill: '#93c5fd', // Tailwind blue-300 equivalent hex
    },
  ];

  const data = testTypes.map((test) => ({
    value: Math.max(Math.log(test.count + test.pending), 0),
    fill: test.fill,
  }));

  return (
    <div className="flex items-center gap-4">
      <div className="relative h-20 w-20">
        {data.every((item) => item.value === 0) ? (
          <div className="flex flex-col shrink-0 items-center justify-center size-full bg-gray-100 rounded-full shadow-sm text-gray-500 mb-4">
            <Triangle />
          </div>
        ) : (
          <div className="absolute left-[-31px] top-0 bottom-0">
            <FunnelChart width={150} height={80}>
              <Funnel dataKey="value" data={data} reversed isAnimationActive={false}>
                <LabelList position="right" fill="#000" stroke="none" dataKey="name" />
              </Funnel>
            </FunnelChart>
          </div>
        )}
      </div>

      <ul className="flex flex-col flex-1 gap-y-1">
        {testTypes.reverse().map((test, index) => (
          <li key={index} className="flex items-center gap-x-2">
            <div className={`w-3 h-3 rounded-full bg-${test.color}`}></div>
            <p className="text-xs text-gray-500">
              {test.type}: <span className="font-medium">{test.count}</span> ({test.pending}{' '}
              pending)
            </p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default FeatureTestPyramidCard;
