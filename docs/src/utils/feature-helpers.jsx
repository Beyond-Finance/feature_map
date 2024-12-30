import React from 'react';

// Constants
export const MAX_SIZE_THRESHOLD = {
  XL: { loc: 3000, files: 20 }
};

// Size Calculations
export function calculateSize(data) {
  const normalizedLOC = data.metrics.lines_of_code / MAX_SIZE_THRESHOLD.XL.loc;
  const normalizedFiles = data.assignments.files ? data.assignments.files.length / MAX_SIZE_THRESHOLD.XL.files : 0;
  return (normalizedLOC * 0.7 + normalizedFiles * 0.3);
}

export function getSizeLabel(sizeScore) {
  if (sizeScore <= 0.2) return 'XS';
  if (sizeScore <= 0.4) return 'S';
  if (sizeScore <= 0.6) return 'M';
  if (sizeScore <= 0.8) return 'L';
  return 'XL';
}

export function getSizeColor(sizeScore) {
  if (sizeScore <= 0.2) return 'bg-green-100 text-green-800';
  if (sizeScore <= 0.4) return 'bg-blue-100 text-blue-800';
  if (sizeScore <= 0.6) return 'bg-violet-100 text-violet-800';
  if (sizeScore <= 0.8) return 'bg-amber-100 text-amber-800';
  return 'bg-red-100 text-red-800';
}

export function getFilledPills(sizeScore) {
  if (sizeScore <= 0.2) return 1;
  if (sizeScore <= 0.4) return 2;
  if (sizeScore <= 0.6) return 3;
  if (sizeScore <= 0.8) return 4;
  return 5;
}

export function formatNumber(num) {
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'k';
  }
  return num;
}

export function renderTeams(teams) {
  if (!teams || teams.length === 0) {
    return (
      <span className="text-gray-400 italic text-sm">
        No team assigned
      </span>
    );
  }

  if (teams.length > 1) {
    return <p>{teams[0]} + {teams.length - 1}</p>;
  }

  return <p>{teams[0]}</p>;
}

// Test Coverage Helpers
export function getTestCoverageInfo(data) {
  if (!data.test_coverage) return { percent: 0, status: 'Missing Coverage', color: 'transparent' };

  const percent = (data.test_coverage.hits / data.test_coverage.lines) * 100;

  if (percent >= 98) return {
    percent,
    status: 'High Coverage',
    color: '#22c55e'
  };

  if (percent >= 95) return {
    percent,
    status: 'Medium Coverage',
    color: '#facc15'
  };

  return {
    percent,
    status: 'Low Coverage',
    color: '#ef4444'
  };
}
