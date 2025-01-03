import React from 'react';
import { Info, Proportions } from 'lucide-react';
import { ResponsiveContainer, PieChart, Pie } from 'recharts';
import { getSizeLabel, getFeatureSizeColor, featureSizes } from '../utils/feature-helpers';

const FeatureSizeDataCard = ({ features }) => {
  const distribution = Object.values(features).reduce((distribution, currentFeature) => {
    const sizeScore = currentFeature.metrics.featureSize.percentOfMax;

    if (sizeScore !== undefined && sizeScore !== null) {
      const category = getSizeLabel(sizeScore);
      distribution[category]++;
    }
    return distribution;
  }, { xs: 0, s: 0, m: 0, l: 0, xl: 0 } );

  const sizeDistribution = Object.entries(distribution).map(([name, value], index) => ({
    name,
    value,
    fill: [
      getFeatureSizeColor(featureSizes.xs).hex,
      getFeatureSizeColor(featureSizes.s).hex,
      getFeatureSizeColor(featureSizes.m).hex,
      getFeatureSizeColor(featureSizes.l).hex,
      getFeatureSizeColor(featureSizes.xl).hex,
    ][index]
  })).filter(({ value }) => value > 0);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            <Proportions className="size-5" />
          </div>
          <span className="flex pl-2">Feature Size</span>
        </h3>

        <div className="relative flex-shrink-0 group">
          <Info className="size-4 text-gray-400" />

          <div className="absolute whitespace-wrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2 w-48">
            Feature Size distribution by category: shows how many features fall into each complexity level from X-Small (simplest) to X-Large (most complex)
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
              />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <ul className="flex flex-col flex-1 gap-y-1">
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getFeatureSizeColor(featureSizes.xs).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.xs}</span>
            </div>
            <p className="text-xs text-gray-500">
              X-Small Features
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getFeatureSizeColor(featureSizes.s).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.s}</span>
            </div>
            <p className="text-xs text-gray-500">
              Small Features
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getFeatureSizeColor(featureSizes.m).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.m}</span>
            </div>
            <p className="text-xs text-gray-500">
              Medium Features
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getFeatureSizeColor(featureSizes.l).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.l}</span>
            </div>
            <p className="text-xs text-gray-500">
              Large Features
            </p>
          </li>
          <li className="flex items-center gap-x-2">
            <div className={`rounded size-5 flex items-center justify-center ${getFeatureSizeColor(featureSizes.xl).class}`}>
              <span className="font-semibold text-white text-xs">{distribution.xl}</span>
            </div>
            <p className="text-xs text-gray-500">
              X-Large Features
            </p>
          </li>
        </ul>
      </div>
    </div>

  );
};

export default FeatureSizeDataCard;
