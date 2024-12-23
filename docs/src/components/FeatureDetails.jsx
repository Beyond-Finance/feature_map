import React from 'react';
import { Users, FileCode, FolderTree, Shapes, GitCompareArrows, ExternalLink } from 'lucide-react';
import { renderTeams } from '../utils/feature-helpers';

export default function FeatureDetails({name, feature}) {
  return(
    <div className="bg-white p-4 rounded-lg border border-gray-200 h-fit">
      <div className="mb-6">
        <h2 className="text-lg font-bold text-gray-800 mb-2">{name}</h2>

        {feature.description && (
          <p className="text-sm md:text-base text-gray-600">{feature.description}</p>
        )}
      </div>

      <h3 className="text-sm font-medium text-gray-900 mb-3">Metrics</h3>

      <ul className="mb-6 space-y-2">
        <li className="flex items-center gap-2">
          <div className="flex-shrink-0">
            <FolderTree className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">{feature.assignments.files ? feature.assignments.files.length : 0} Total Files</p>
        </li>

        <li className="flex items-center gap-2">
          <div className="flex-shrink-0">
            <Shapes className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">{feature.metrics.abc_size || 0} ABC Size</p>
        </li>

        <li className="flex items-center gap-2">
          <div className="flex-shrink-0">
            <FileCode className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">{feature.metrics.lines_of_code || 0} Lines of Code</p>
        </li>

        <li className="flex items-center gap-2">
          <div className="flex-shrink-0">
            <GitCompareArrows className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">{feature.metrics.cyclomatic_complexity || 0} Cyclomatic Complexity</p>
        </li>
      </ul>

      <div className="space-y-4 mb-6">
        <div>
          <h3 className="text-sm font-medium text-gray-900 mb-3">Teams</h3>

          <div className="flex gap-2">
            <div className="flex items-center justify-center flex-shrink-0">
              <Users className="size-4 text-gray-500" />
            </div>

            {renderTeams(feature.assignments.teams)}
          </div>
        </div>
      </div>

      <div className="mb">
        <h3 className="text-sm font-medium text-gray-900 mb-3">Resources</h3>

        <ul className="mb-6 space-y-2">
          <li className="flex items-center gap-2">
            <div className="flex-shrink-0">
              <ExternalLink className="size-4 text-gray-500" />
            </div>
            {feature.documentation_link ? (
                <a href={feature.documentation_link} target="_blank" className="text-sm text-gray-700 hover:underline">Feature Documentation</a>
            ) : <span className="text-gray-400 italic text-sm">Missing documentation link</span>}
          </li>

          <li className="flex items-center gap-2">
            <div className="flex-shrink-0">
              <ExternalLink className="size-4 text-gray-500" />
            </div>
            {feature.dashboard_link ? (
                <a href={feature.dashboard_link} target="_blank" className="text-sm text-gray-700 hover:underline">New Relic Dashboard</a>
            ) : <span className="text-gray-400 italic text-sm">Missing New Relic Dashboard</span>}
          </li>
        </ul>
      </div>
    </div>
  )
}
