import FeatureSizeDataCard from '../components/FeatureSizeDataCard';
import HealthScoreDataCard from '../components/HealthScoreDataCard';
import TestCoverageDataCard from '../components/TestCoverageDataCard';

export default function Digest({ features }) {
  console.log('features', features)

  const healthScores = Object.entries(features)
    .map(([name, data]) => ({
      name,
      health: data.metrics.health.overall || 0
    }))
    .sort((a, b) => a.health - b.health)
    .slice(0, 5);



  const testCoverageScores = Object.entries(features)
    .map(([name, data]) => ({
      name,
      score: data.metrics.testCoverage.score || 0
    }))
    .sort((a, b) => a.score - b.score)
    .slice(0, 5);

  console.log(testCoverageScores)

  return (
    <div className="max-w-7xl mx-auto p-4 md:p-8">
      <div className="mb-8">
        <h2 className="mt-3 text-3xl font-bold tracking-tight text-gray-800">Feature Management Digest</h2>
      </div>

      <div className="mb-8">
        <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><FeatureSizeDataCard features={features} /></li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><HealthScoreDataCard features={features} /></li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><TestCoverageDataCard features={features} /></li>
        </ul>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="px-4 py-6 border border-gray-200 bg-white rounded-lg">
          <h3>Bottom 5 in health score</h3>
          {/* TODO: add list of the 5 features  with the lowest health scores */}
          <ul>
            {healthScores.map((feature) => (
              <li key={feature.name} className="flex items-center justify-between py-2">
                <span className="font-medium">{feature.name}</span>
                <span>
                  {feature.health.toFixed(2)}
                </span>
              </li>
            ))}
          </ul>
        </div>

        <div className="px-4 py-6 border border-gray-200 bg-white rounded-lg">
          <h3>Bottom 5 in test coverage</h3>
          {/* TODO: add list of the 5 features  with the lowest test coverage */}
          {testCoverageScores.map((feature) => (
            <li key={feature.name} className="flex items-center justify-between py-2">
              <span className="font-medium">{feature.name}</span>
              <span>
                {feature.score.toFixed(2)}
              </span>
            </li>
          ))}
          <ul>
            <li></li>
          </ul>
        </div>
      </div>
    </div>
  );
}
