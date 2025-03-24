import React from 'react';
import {
  Hash,
  Users,
  FileCode,
  FolderTree,
  Shapes,
  GitCompareArrows,
  ExternalLink,
} from 'lucide-react';
import { config } from '../utils/config';

export default function FeatureDetails({ name, feature }) {
  const { project } = config;
  const featureFilters = `is:pr label:"${feature.label}"`;
  const encodedQuery = encodeURIComponent(featureFilters);
  const filteredPullRequestUrl = `${project.repository.url}/pulls?q=${encodedQuery}`;

  return (
    <div className="bg-white p-4 rounded-lg border border-gray-200 h-fit">
      <div className="mb-6">
        <h3 className="text-sm font-medium text-gray-900 mb-3">Description</h3>

        {feature.description && (
          <p className="text-sm md:text-base text-gray-600">{feature.description}</p>
        )}
      </div>

      <h3 className="text-sm font-medium text-gray-900 mb-3">Metrics</h3>

      <ul className="mb-6 space-y-2">
        <li className="flex items-center gap-2">
          <div className="shrink-0">
            <FolderTree className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">
            {feature.assignments.files ? feature.assignments.files.length : 0} Total Files
          </p>
        </li>

        <li className="flex items-center gap-2">
          <div className="shrink-0">
            <Shapes className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">
            {(feature.metrics.abc_size || 0).toFixed(2)} ABC Size
          </p>
        </li>

        <li className="flex items-center gap-2">
          <div className="shrink-0">
            <FileCode className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">
            {feature.metrics.lines_of_code || 0} Lines of Code
          </p>
        </li>

        <li className="flex items-center gap-2">
          <div className="shrink-0">
            <GitCompareArrows className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">
            {feature.metrics.cyclomatic_complexity || 0} Cyclomatic Complexity
          </p>
        </li>

        <li className="flex items-center gap-2">
          <div className="shrink-0">
            <Hash className="size-4 text-gray-500" />
          </div>
          <p className="text-sm text-gray-700">
            {feature.metrics.todo_locations
              ? Object.keys(feature.metrics.todo_locations).length
              : 0}{' '}
            TODO Comments
          </p>
        </li>
      </ul>

      <div className="space-y-4 mb-6">
        <div>
          <h3 className="text-sm font-medium text-gray-900 mb-3">Teams</h3>

          <ul className="flex flex-col gap-y-1">
            {feature.assignments.teams ? (
              feature.assignments.teams.map((team) => {
                return (
                  <li key={team} className="text-sm text-gray-700 flex gap-2">
                    <div className="flex items-center justify-center shrink-0">
                      <Users className="size-4 text-gray-500" />
                    </div>
                    {team}
                  </li>
                );
              })
            ) : (
              <li className="text-sm text-gray-700 flex gap-2">
                <div className="flex items-center justify-center shrink-0">
                  <Users className="size-4 text-gray-500" />
                </div>
                <span className="text-gray-400 italic text-sm">No teams assigned</span>
              </li>
            )}
          </ul>
        </div>
      </div>

      <div className="mb">
        <h3 className="text-sm font-medium text-gray-900 mb-3">Resources</h3>

        <ul className="mb-6 space-y-2">
          <li className="flex items-center gap-2">
            <div className="shrink-0">
              <ExternalLink className="size-4 text-gray-500" />
            </div>
            <a
              href={filteredPullRequestUrl}
              target="_blank"
              className="text-sm text-gray-700 hover:underline"
              rel="noreferrer"
            >
              Feature Pull Requests
            </a>
          </li>

          <li className="flex items-center gap-2">
            <div className="shrink-0">
              <ExternalLink className="size-4 text-gray-500" />
            </div>
            {feature.documentation_link ? (
              <a
                href={feature.documentation_link}
                target="_blank"
                className="text-sm text-gray-700 hover:underline"
                rel="noreferrer"
              >
                Feature Documentation
              </a>
            ) : (
              <span className="text-gray-400 italic text-sm">Missing documentation link</span>
            )}
          </li>

          <li className="flex items-center gap-2">
            <div className="shrink-0">
              <ExternalLink className="size-4 text-gray-500" />
            </div>
            {feature.dashboard_link ? (
              <a
                href={feature.dashboard_link}
                target="_blank"
                className="text-sm text-gray-700 hover:underline"
                rel="noreferrer"
              >
                New Relic Dashboard
              </a>
            ) : (
              <span className="text-gray-400 italic text-sm">Missing New Relic Dashboard</span>
            )}
          </li>
        </ul>
      </div>
    </div>
  );
}
