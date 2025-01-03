import FeaturesTable from '../components/FeaturesTable';
import FeaturesTreemap from '../components/FeaturesTreemap';
import FeatureSizeDataCard from '../components/FeatureSizeDataCard';
import HealthScoreDataCard from '../components/HealthScoreDataCard';
import TestCoverageDataCard from '../components/TestCoverageDataCard';

export default function Dashboard({ features }) {
  return (
    <div className="max-w-7xl mx-auto p-4 md:p-8">
      <div className="mb-8">
        <h2 className="mt-3 text-3xl font-bold tracking-tight text-gray-800">Feature Dashboard</h2>
      </div>

      <div className="mb-8">
        <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><FeatureSizeDataCard features={features} /></li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><HealthScoreDataCard features={features} /></li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg"><TestCoverageDataCard features={features} /></li>
        </ul>
      </div>

      <div className="mb-8 bg-white p-4 rounded-lg shadow w-full">
        <FeaturesTreemap data={features} />
      </div>

      <FeaturesTable features={features} />
    </div>
  );
}
