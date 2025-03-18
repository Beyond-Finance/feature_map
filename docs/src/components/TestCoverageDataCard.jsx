import React from 'react';
import { Info, FlaskConical } from 'lucide-react';
import { ResponsiveContainer, PieChart, Pie } from 'recharts';
import { config } from '../utils/config';
import { getTestCoverageLabel, getTestCoverageColor } from '../utils/feature-helpers';
import { Tooltip, TooltipButton, TooltipPanel } from './Tooltip';

const TestCoverageDataCard = ({ features }) => {
  const distribution = Object.values(features).reduce(
    (distribution, currentFeature) => {
      const sizeScore = currentFeature.additional_metrics.test_coverage.score || 0;

      if (sizeScore !== undefined && sizeScore !== null) {
        const category = getTestCoverageLabel(sizeScore);
        distribution[category]++;
      }
      return distribution;
    },
    { poor: 0, fair: 0, good: 0 }
  );

  const { minimum_thresholds: coverageScores } = config.project.documentation_site.test_coverage;
  const sizeDistribution = Object.entries(distribution)
    .map(([name, value], index) => ({
      name,
      value,
      fill: [
        getTestCoverageColor(coverageScores.poor).hex,
        getTestCoverageColor(coverageScores.fair).hex,
        getTestCoverageColor(coverageScores.good).hex,
      ][index],
    }))
    .filter(({ value }) => value > 0);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            <FlaskConical className="size-5" />
          </div>
          <span className="flex pl-2">Test Coverage</span>
        </h3>

        <Tooltip>
          <TooltipButton>
            <Info className="size-4 text-gray-400" />
          </TooltipButton>

          <TooltipPanel>
            Test coverage is determined by using CodeCov data (lines, hits, misses) to calculate a
            percentage score, from 0-100%, relative to the other features in the codebase. A
            qualitative coverage ranking is assigned to each feature, which can be managed which can
            be managed via `.feature_map/config.yml`.
          </TooltipPanel>
        </Tooltip>
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
              ></Pie>
            </PieChart>
          </ResponsiveContainer>
        </div>

        <ul className="flex flex-col flex-1 gap-y-1">
          <li className="flex items-center gap-x-2">
            <div
              className={`shrink-0 rounded-sm size-5 flex items-center justify-center ${getTestCoverageColor(coverageScores.poor).class}`}
            >
              <span className="font-semibold text-white text-xs">{distribution.poor}</span>
            </div>
            <p className="text-xs text-gray-500">Features with poor test coverage</p>
          </li>
          <li className="flex items-center gap-x-2">
            <div
              className={`shrink-0 rounded-sm size-5 flex items-center justify-center ${getTestCoverageColor(coverageScores.fair).class}`}
            >
              <span className="font-semibold text-white text-xs">{distribution.fair}</span>
            </div>
            <p className="text-xs text-gray-500">Features with acceptable test coverage</p>
          </li>
          <li className="flex items-center gap-x-2">
            <div
              className={`shrink-0 rounded-sm size-5 flex items-center justify-center ${getTestCoverageColor(coverageScores.good).class}`}
            >
              <span className="font-semibold text-white text-xs">{distribution.good}</span>
            </div>
            <p className="text-xs text-gray-500">Features with great test coverage</p>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default TestCoverageDataCard;
