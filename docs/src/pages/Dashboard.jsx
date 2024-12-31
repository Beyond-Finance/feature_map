import { useState, useEffect } from 'react';
import FeaturesTable from '../components/FeaturesTable';
import MetricCard from '../components/MetricCard';
import FeaturesTreemap from '../components/FeaturesTreemap';
import { FileJson, GitGraphIcon, ShapesIcon } from 'lucide-react';

export default function Dashboard({ features }) {
  const [metrics, setMetrics] = useState({
    abcSize: 0,
    linesOfCode: 0,
    complexity: 0
  });

  useEffect(() => {
    const calculateAverages = () => {
      const values = Object.values(features).reduce((acc, feature) => {
        acc.abcSize.push(feature.metrics.abc_size);
        acc.linesOfCode.push(feature.metrics.lines_of_code);
        acc.complexity.push(feature.metrics.cyclomatic_complexity);
        return acc;
      }, { abcSize: [], linesOfCode: [], complexity: [] });

      const average = arr => Math.round((arr.reduce((a, b) => a + b, 0) / arr.length) * 100) / 100;

      setMetrics({
        abcSize: average(values.abcSize),
        linesOfCode: average(values.linesOfCode),
        complexity: average(values.complexity)
      });
    };

    calculateAverages();
  }, [features]);

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
              value={metrics.abcSize}
              tooltip="Average abc size across all features"
              icon={<ShapesIcon className="size-5" />  }
            />
          </li>

          <li>
            <MetricCard
              title="Lines of Code"
              value={metrics.linesOfCode}
              tooltip="Average lines of code across all features"
              icon={<FileJson className="size-5" />}
            />
          </li>

          <li>
            <MetricCard
              title="Complexity"
              value={metrics.complexity}
              tooltip="Average cyclomatic complexity across all features"
              icon={<GitGraphIcon className="size-5"/>}
            />
          </li>
        </ul>
      </div>

      <div className="mb-8 bg-white p-4 rounded-lg shadow w-full">
        <FeaturesTreemap data={features} />
      </div>

      <FeaturesTable features={features} />
    </div>
  );
}
