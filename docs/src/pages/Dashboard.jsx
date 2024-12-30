import { useState, useEffect } from 'react';
import FeaturesTable from '../components/FeaturesTable';
import MetricCard from '../components/MetricCard';
import FeaturesTreeMap from '../components/FeaturesTreemap';
import { FileJson, GitGraphIcon, ShapesIcon } from 'lucide-react';

export default function Dashboard({ features }) {
  const totals = Object.values(features).reduce((acc, feature) => {
    const { abcSize, linesOfCode, cyclomaticComplexity } = acc
    return {
      abcSize: abcSize + feature.metrics.abc_size,
      linesOfCode: linesOfCode + feature.metrics.lines_of_code,
      cyclomaticComplexity: cyclomaticComplexity + feature.metrics.cyclomatic_complexity,
    }
  }, { abcSize: 0, linesOfCode: 0, cyclomaticComplexity: 0})

  const totalFeatures = Object.keys(features).length

  return (
    <div className="max-w-7xl mx-auto p-4 md:p-8">
      <div className="mb-8">
        <h2 className="mt-3 text-3xl font-bold tracking-tight text-gray-800">Feature Dashboard</h2>
      </div>

      <div className="mb-8">
        <ul className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <li>
            <MetricCard
              title="ABC Size"
              value={(totals.abcSize / totalFeatures).toFixed(2)}
              tooltip="Average abc size across all features"
              icon={<ShapesIcon className="size-5" />  }
            />
          </li>

          <li>
            <MetricCard
              title="Lines of Code"
              value={(totals.linesOfCode / totalFeatures).toFixed(2)}
              tooltip="Average lines of code across all features"
              icon={<FileJson className="size-5" />}
            />
          </li>

          <li>
            <MetricCard
              title="Complexity"
              value={(totals.cyclomaticComplexity / totalFeatures).toFixed(2)}
              tooltip="Average cyclomatic complexity across all features"
              icon={<GitGraphIcon className="size-5"/>}
            />
          </li>
        </ul>
      </div>

      <div className="mb-8 bg-white p-4 rounded-lg shadow w-full">
        <FeaturesTreeMap data={features} />
      </div>

      <FeaturesTable features={features} />
    </div>
  );
}
