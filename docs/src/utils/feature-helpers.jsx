import React from 'react';
import { config } from './config'

const {
  size_percentile: { minimum_thresholds: featureSizeThresholds  },
  test_coverage: { minimum_thresholds: testCoverageThresholds }
} = config.project.documentation_site

export const getFeatureSizeColor = (sizeScore) => {
  if (sizeScore === undefined || sizeScore === null) return { hex: '#f3f4f6', class: 'bg-gray-100' }
  if (sizeScore >= featureSizeThresholds.xl) return { hex: '#1e3a8a', class: 'bg-blue-900' };
  if (sizeScore >= featureSizeThresholds.l) return { hex: '#1e40af', class: 'bg-blue-800' };
  if (sizeScore >= featureSizeThresholds.m) return { hex: '#2563eb', class: 'bg-blue-600' };
  if (sizeScore >= featureSizeThresholds.s) return { hex: '#3b82f6', class: 'bg-blue-500'};

  // xs
  return { hex: '#93c5fd', class: 'bg-blue-300'};
}

export const getFeatureSizeLabel = (sizeScore) => {
  if (sizeScore >= featureSizeThresholds.xl) return 'xl';
  if (sizeScore >= featureSizeThresholds.l) return 'l';
  if (sizeScore >= featureSizeThresholds.m) return 'm';
  if (sizeScore >= featureSizeThresholds.s) return 's';

  return 'xs';
}

export const getFilledPills = (sizeScore) => {
  if (sizeScore >= featureSizeThresholds.xl) return 5;
  if (sizeScore >= featureSizeThresholds.l) return 4;
  if (sizeScore >= featureSizeThresholds.m) return 3;
  if (sizeScore >= featureSizeThresholds.s) return 2;

  // xs
  return 1;
}

export const getTestCoverageColor = (coverageScore) => {
  if (coverageScore === undefined || coverageScore === null) return { hex: 'transparent', class: 'bg-transparent' }
  if (coverageScore >= testCoverageThresholds.good) return { hex: '#22c55e', class: 'bg-green-500' };
  if (coverageScore >= testCoverageThresholds.fair) return { hex: '#eab308', class: 'bg-yellow-500' };

  // poor
  return {
    hex: '#ef4444',
    class: 'bg-red-500'
  };
}

export const getTestCoverageLabel = (coverageScore) => {
  if (coverageScore >= testCoverageThresholds.good) return 'good';
  if (coverageScore >= testCoverageThresholds.fair) return 'fair';

  return 'poor';
}

export const formatNumber = (num) => {
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'k';
  }
  return num;
}

export const renderTeams = (teams) => {
  if (!teams || teams.length === 0) {
    return (
      <span className="text-gray-400 italic text-sm">
        No team assigned
      </span>
    );
  }

  if (teams.length > 1) {
    return <p className="text-sm text-gray-700">{teams[0]} + {teams.length - 1}</p>;
  }

  return <p className="text-sm text-gray-700">{teams[0]}</p>;
}
