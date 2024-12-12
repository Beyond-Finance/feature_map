import { useState, useEffect } from 'react';
import FeatureTable from './components/FeatureTable';
import MetricCard from './components/MetricCard';
import FeatureTreemap from './components/FeatureTreemap';
import sampleFeatures from './data/sample_features';
import AbcSizeIcon from './components/icons/AbcSizeIcon'
import LinesOfCodeIcon from './components/icons/LinesOfCodeIcon'
import CyclomaticComplexityIcon from './components/icons/CyclomaticComplexityIcon'

export default function App() {
  const features = window.FEATURES || useState(sampleFeatures)[0];
  console.log(features);
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
        <ul className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <MetricCard
            title="ABC Size"
            value={metrics.abcSize}
            tooltip="Average abc size across all features"
            icon={<AbcSizeIcon />}
          />
          <MetricCard
            title="Lines of Code"
            value={metrics.linesOfCode}
            tooltip="Average lines of code across all features"
            icon={<LinesOfCodeIcon />}
          />
          <MetricCard
            title="Complexity"
            value={metrics.complexity}
            tooltip="Average cyclomatic complexity across all features"
            icon={<CyclomaticComplexityIcon />}
          />
        </ul>
      </div>
      <div className="mb-8">
        <FeatureTreemap data={features} />
      </div>
      <FeatureTable features={features} />
    </div>
  );
}
