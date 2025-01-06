import React from 'react';
import { Info, FlaskConical } from 'lucide-react';
import { ResponsiveContainer, PieChart, Pie } from 'recharts';
import { config } from '../utils/config'
import { getTestCoverageLabel, getTestCoverageColor} from '../utils/feature-helpers';

const TestCoverageDataCard = ({ features }) => {
  const distribution = Object.values(features).reduce((distribution, currentFeature) => {
    const sizeScore = currentFeature.metrics.testCoverage.score;

    if (sizeScore !== undefined && sizeScore !== null) {
      const category = getTestCoverageLabel(sizeScore);
      distribution[category]++;
    }
    return distribution;
  }, { poor: 0, fair: 0, good: 0 });

  const { minimum_thresholds: sizePercentileThresholds } = config.project.documentation_site.test_coverage
  const sizeDistribution = Object.entries(distribution).map(([name, value], index) => ({
    name,
    value,
    fill: [
      getTestCoverageColor(sizePercentileThresholds.poor).hex,
      getTestCoverageColor(sizePercentileThresholds.fair).hex,
      getTestCoverageColor(sizePercentileThresholds.good).hex,
    ][index]
  })).filter(({ value }) => value > 0);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            <FlaskConical className="size-5"/>
          </div>
          <span className="flex pl-2">Test Coverage</span>
        </h3>

        <div className="relative flex-shrink-0 group">
          <Info className="size-4 text-gray-400" />

          <div className="absolute whitespace-wrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2 w-48">
            Test Coverage distribution by category: shows how many features fall into each level from poor to good
          </div>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="relative h-28 w-28">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={sizeDistribution}
                dataKey="value"
                nameKey="name"
                innerRadius="70%"
                outerRadius="100%"
                paddingAngle={2}
              >
              </Pie>
            </PieChart>
          </ResponsiveContainer>
        </div>

        <ul className="flex flex-col flex-1 gap-y-1">
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getTestCoverageColor(sizePercentileThresholds.poor).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.poor}</span>
            </div>
            <p className="text-xs text-gray-500">
              <span className="lg:hidden xl:inline-block">Features with</span> poor coverage
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getTestCoverageColor(sizePercentileThresholds.fair).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.fair}</span>
            </div>
            <p className="text-xs text-gray-500">
              <span className="lg:hidden xl:inline-block">Features with</span> fair coverage
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getTestCoverageColor(sizePercentileThresholds.good).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.good}</span>
            </div>
            <p className="text-xs text-gray-500">
              <span className="lg:hidden xl:inline-block">Features with</span> good coverage
            </p>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default TestCoverageDataCard;
