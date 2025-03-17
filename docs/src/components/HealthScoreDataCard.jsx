import React from 'react';
import { Info, Gauge } from 'lucide-react';
import { ResponsiveContainer, PieChart, Pie } from 'recharts';
import { getHealthScoreLabel, getHealthScoreColor, healthScores } from '../utils/health-score';
import { Tooltip, TooltipButton, TooltipPanel } from './Tooltip';

const HealthScoreDataCard = ({ features }) => {
  const distribution = Object.values(features).reduce(
    (distribution, currentFeature) => {
      const sizeScore = currentFeature.additional_metrics.health.overall || 0;

      if (sizeScore !== undefined && sizeScore !== null) {
        const category = getHealthScoreLabel(sizeScore);
        distribution[category]++;
      }
      return distribution;
    },
    { needsAttention: 0, needsImprovement: 0, healthy: 0 }
  );

  const sizeDistribution = Object.entries(distribution)
    .map(([name, value], index) => ({
      name,
      value,
      fill: [
        getHealthScoreColor(healthScores.needsAttention).hex,
        getHealthScoreColor(healthScores.needsImprovement).hex,
        getHealthScoreColor(healthScores.healthy).hex,
      ][index],
    }))
    .filter(({ value }) => value > 0);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            <Gauge className="size-5" />
          </div>
          <span className="flex pl-2">Health Score</span>
        </h3>

        <Tooltip>
          <TooltipButton>
            <Info className="size-4 text-gray-400" />
          </TooltipButton>

          <TooltipPanel>
            Feature health is determined by combining a weighted score for test coverage, code
            complexity, and encapsulation into a composite score from 0-100%. Each feature is then
            grouped into a categories ranging from low (needs attention) to good (healthy), which
            can be managed via `.feature_map/config.yml`.
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
              className={`flex-shrink-0 rounded size-5 flex items-center justify-center ${getHealthScoreColor(healthScores.needsAttention).class}`}
            >
              <span className="font-semibold text-white text-xs">
                {distribution.needsAttention}
              </span>
            </div>
            <p className="text-xs text-gray-500">
              <span className="lg:hidden xl:inline-block">Features</span> need attention
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div
              className={`flex-shrink-0 rounded size-5 flex items-center justify-center ${getHealthScoreColor(healthScores.needsImprovement).class}`}
            >
              <span className="font-semibold text-white text-xs">
                {distribution.needsImprovement}
              </span>
            </div>
            <p className="text-xs text-gray-500">
              <span className="lg:hidden xl:inline-block">Features</span> need improvement
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div
              className={`flex-shrink-0 rounded size-5 flex items-center justify-center ${getHealthScoreColor(healthScores.healthy).class}`}
            >
              <span className="font-semibold text-white text-xs">{distribution.healthy}</span>
            </div>
            <p className="text-xs text-gray-500">Healthy Features</p>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default HealthScoreDataCard;
