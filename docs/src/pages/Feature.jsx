import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { Info, Gauge, FlaskConical, Proportions } from 'lucide-react';
import FileExplorer from '../components/FileExplorer';
import FeatureDetails from '../components/FeatureDetails';
import FeatureCard from '../components/FeatureCard';
import FeatureTreemap from '../components/FeatureTreemap';
import {
  calculateHealthScore,
  getHealthScoreStatus,
  getHealthScoreColor,
  calculateSize,
  getSizeLabel,
  getFilledPills,
  formatNumber,
  getTestCoverageInfo
} from '../utils/feature-helpers';

export default function Feature({ features }) {
  const { name } = useParams();
  const feature = features[name];

  if (!feature) {
    return (
      <div className="max-w-7xl mx-auto p-4 md:p-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h1 className="text-xl font-bold text-red-600">Feature Not Found</h1>
          <p className="mt-2">Could not find feature: {name}</p>
          <Link to="/" className="text-blue-600 hover:text-blue-800 mt-4 inline-block">
            ← Back to Features
          </Link>
        </div>
      </div>
    );
  }

  const healthScore = calculateHealthScore(feature);
  const sizeScore = calculateSize(feature);
  const coverageInfo = getTestCoverageInfo(feature);
  const filledPills = getFilledPills(sizeScore);

  console.log('Health Score:', healthScore * 100);
  console.log('Coverage:', coverageInfo.percent);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <Link to="/" className="text-gray-600 hover:text-blue-800 block text-sm font-normal">
          ← Back to Dashboard
        </Link>
      </div>

      <div className="grid grid-cols-12 gap-8">
        {/* Left Column */}
        <div className="col-span-12 md:col-span-3">
          <FeatureDetails name={name} feature={feature} />
        </div>

        {/* Right Column */}
        <div className="col-span-12 md:col-span-9">
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
            <FeatureCard
              title="Health Score"
              value={(healthScore * 100)}
              suffix="%"
              tooltip="Health score calculations are still a WIP"
              icon={<Gauge />}
              color={getHealthScoreColor(healthScore)}
              subtext={<span className="font-bold">{getHealthScoreStatus(healthScore)}</span>}
              secondaryText={<div className="text-[10px] text-gray-500">
                {formatNumber(feature.metrics.lines_of_code)} lines • {feature.assignments.files.length} files
              </div>}
            />

            <FeatureCard
              title="Test Coverage"
              value={coverageInfo.percent}
              suffix="%"
              tooltip="Test coverage is pulled from CodeCov"
              icon={<FlaskConical />}
              color={coverageInfo.color}
              subtext={<span className="font-bold">{coverageInfo.status}</span>}
              secondaryText={feature.test_coverage ?
                <><span className="font-bold">{feature.test_coverage.hits}</span> / <span className="font-bold">{feature.test_coverage.lines}</span> lines covered</> :
                'Test coverage data not available for this particular feature'
              }
            />

            <div className="flex flex-col gap-6 px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
              <div className="flex items-center justify-between">
                <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
                  <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
                    <Proportions />
                  </div>
                  <span className="flex pl-2">Feature Size</span>
                </h3>

                <div className="relative flex-shrink-0 group">
                  <Info className="size-4 text-gray-400" />
                  <div className="absolute whitespace-nowrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2">
                    Relative size of feature using lines of code and file counts
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <div className="relative h-20 flex items-center">
                  <div className="text-2xl font-bold">{getSizeLabel(sizeScore)}</div>
                </div>

                <div className="flex flex-col gap-y-2">
                  <div className="flex gap-1.5 items-center">
                    {[1, 2, 3, 4, 5].map(index => (
                      <div
                        key={index}
                        className={`h-6 w-1.5 rounded ${index <= filledPills ? 'bg-blue-500' : 'bg-gray-300'}`}
                      />
                    ))}
                  </div>
                </div>

                <div>
                  <div className="text-[10px] text-gray-500">{feature.assignments.files.length} files</div>
                  <div className="text-[10px] text-gray-500">{formatNumber(feature.metrics.lines_of_code)} lines</div>
                </div>
              </div>
            </div>
          </div>

          {feature.assignments.files.length > 0 ? (
            <>
              <div className="h-[600px] bg-white rounded-lg border border-gray-200 shadow-sm mb-8">
                <FeatureTreemap files={feature.assignments.files} />
              </div>

              <FileExplorer files={feature.assignments.files} />
            </>
          ) : (
            <div className="h-[300px] bg-white rounded-lg border border-gray-200 shadow-sm mb-8">
              <div className="flex items-center justify-center h-full text-gray-500">
                No files found for this feature
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
