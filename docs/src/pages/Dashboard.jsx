import { useState, useEffect } from 'react';
import { averages, scores } from '../utils/metrics';
import { healthScore } from '../utils/health-score';
import FeaturesTable from '../components/FeaturesTable';
import MetricCard from '../components/MetricCard';
import FeaturesTreeMap from '../components/FeaturesTreemap';
import { FileJson, GitGraphIcon, ShapesIcon } from 'lucide-react';

export default function Dashboard({ features }) {
  const {
    abcSize: averageAbcSize,
    linesOfCode: averageLinesOfCode,
    cyclomaticComplexity: averageCyclomaticComplexity,
  } = averages({ features })

  const { cyclomaticComplexityScores, encapsulationScores, testCoverageScores } = scores({ features })

  const annotatedFeatures = Object.entries(features).reduce((accumulatingFeatures, [featureName, feature]) => {
    const cyclomaticComplexity = cyclomaticComplexityScores[featureName]
    const encapsulation = encapsulationScores[featureName]
    const testCoverage = testCoverageScores[featureName]

    return {
      ...accumulatingFeatures,
      [featureName]: {
        ...feature,
        scores: {
          encapsulation,
          health: healthScore({ cyclomaticComplexity, encapsulation, testCoverage }),
          cyclomaticComplexity,
          testCoverage,
        }
      }
    }
  }, {})

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
              value={averageAbcSize}
              tooltip="Average abc size across all features"
              icon={<ShapesIcon className="size-5" />  }
            />
          </li>

          <li>
            <MetricCard
              title="Lines of Code"
              value={averageLinesOfCode}
              tooltip="Average lines of code across all features"
              icon={<FileJson className="size-5" />}
            />
          </li>

          <li>
            <MetricCard
              title="Complexity"
              value={averageCyclomaticComplexity}
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
