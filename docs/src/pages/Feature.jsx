import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { Info, Gauge, FlaskConical, Proportions } from 'lucide-react';
import FileExplorer from '../components/FileExplorer';
import FeatureDetails from '../components/FeatureDetails';
import FeatureCard from '../components/FeatureCard';
import FeatureTreemap from '../components/FeatureTreemap';
import {
  getFeatureSizeLabel,
  getFilledPills,
  formatNumber,
  getTestCoverageColor
} from '../utils/feature-helpers';
import {
  getHealthScoreColor,
} from '../utils/health-score';
import { Tooltip, TooltipButton, TooltipPanel } from '../components/Tooltip';

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

  const healthScore = feature.additional_metrics.health.overall;
  const sizeScore = feature.additional_metrics.feature_size.percentOfMax;
  const filledPills = getFilledPills(sizeScore);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <Link to="/" className="text-gray-600 hover:text-blue-800 block text-sm font-normal">
          ← Back to Dashboard
        </Link>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left Column */}
        <div className="col-span-1 lg:col-span-3">
          <FeatureDetails name={name} feature={feature} />
        </div>

        {/* Right Column */}
        <div className="col-span-1 lg:col-span-9">
          <div className="grid md:grid-cols-3 gap-4 mb-8">
            <FeatureCard
              title="Health Score"
              value={healthScore.toFixed(0)}
              suffix="%"
              tooltip="Feature health is determined by combining a weighted score for test coverage, code complexity, and encapsulation into a composite score from 0-100%. Each feature is then grouped into a categories ranging from low (needs attention) to good (healthy), which can be managed via `.feature_map/config.yml`."
              icon={<Gauge />}
              color={getHealthScoreColor(healthScore).hex}
            >
              <ul className="flex flex-col gap-y-1">
                <li className="text-xs text-gray-500">
                  Coverage: {feature.additional_metrics.health.test_coverage_component.health_score.toFixed(0)} / {feature.additional_metrics.health.test_coverage_component.awardable_points}
                </li>
                <li className="text-xs text-gray-500">
                  Complexity: {feature.additional_metrics.health.cyclomatic_complexity_component.health_score.toFixed(0)} / {feature.additional_metrics.health.cyclomatic_complexity_component.awardable_points}
                </li>
                <li className="text-xs text-gray-500">
                  Encapsulation: {feature.additional_metrics.health.encapsulation_component.health_score.toFixed(0)} / {feature.additional_metrics.health.encapsulation_component.awardable_points}
                </li>
              </ul>
            </FeatureCard>

            <FeatureCard
              title="Test Coverage"
              value={feature.additional_metrics.test_coverage.score}
              suffix="%"
              tooltip="Test coverage is determined by using CodeCov data (lines, hits, misses) to calculate a percentage score, from 0-100%, relative to the other features in the codebase. A qualitative coverage ranking is assigned to each feature, which can be managed which can be managed via `.feature_map/config.yml`."
              icon={<FlaskConical />}
              color={getTestCoverageColor(feature.additional_metrics.test_coverage.score).hex}
            >
              <ul className="flex flex-col gap-y-1">
                <li className="text-xs text-gray-500">
                  Hits: {feature.test_coverage ? feature.test_coverage.hits : 0}
                </li>
                <li className="text-xs text-gray-500">
                  Lines: {feature.test_coverage ? feature.test_coverage.lines : 0}
                </li>
                <li className="text-xs text-gray-500">
                  Misses: {feature.test_coverage ? feature.test_coverage.misses : 0}
                </li>
              </ul>
            </FeatureCard>

            <div className="flex flex-col gap-6 px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
              <div className="flex items-center justify-between">
                <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
                  <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
                    <Proportions />
                  </div>
                  <span className="flex pl-2">Feature Size</span>
                </h3>

                <Tooltip>
                  <TooltipButton>
                    <Info className="size-4 text-gray-400" />
                  </TooltipButton>

                  <TooltipPanel>
                    Feature size is determined by analyzing the total number of files and lines of code associated with each feature. Each feature is then grouped
                    into different size bins, which can be configured in the config.yaml file.
                  </TooltipPanel>
                </Tooltip>
              </div>

              <div className="flex items-center gap-4">
                <div className="relative h-20 flex items-center">
                  <div className="text-2xl font-bold uppercase">{getFeatureSizeLabel(sizeScore)}</div>
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
                  <div className="text-[10px] text-gray-500">{feature.assignments.files ? feature.assignments.files.length : 0} files</div>
                  <div className="text-[10px] text-gray-500">{formatNumber(feature.metrics.lines_of_code)} lines</div>
                </div>
              </div>
            </div>
          </div>


          {feature.assignments.files && feature.assignments.files.length > 0 ? (
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
