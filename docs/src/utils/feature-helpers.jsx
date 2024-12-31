import React from 'react';

// Constants
export const MAX_SIZE_THRESHOLD = {
  XL: { loc: 3000, files: 20 }
};

const sizes = {
  xs: 5,
  s: 20,
  m: 70,
  l: 95,
}

export function getSizeLabel(sizeScore) {
  if (sizeScore <= sizes.xs) return 'XS';
  if (sizeScore <= sizes.s) return 'S';
  if (sizeScore <= sizes.m) return 'M';
  if (sizeScore <= sizes.l) return 'L';
  return 'XL';
}

export function getSizeColor(sizeScore) {
  if (sizeScore <= sizes.xs) return 'bg-green-100 text-green-800';
  if (sizeScore <= sizes.s) return 'bg-blue-100 text-blue-800';
  if (sizeScore <= sizes.m) return 'bg-violet-100 text-violet-800';
  if (sizeScore <= sizes.l) return 'bg-amber-100 text-amber-800';
  return 'bg-red-100 text-red-800';
}

export function getFilledPills(sizeScore) {
  if (sizeScore <= sizes.xs) return 1;
  if (sizeScore <= sizes.s) return 2;
  if (sizeScore <= sizes.m) return 3;
  if (sizeScore <= sizes.l) return 4;
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
export function getTestCoverageColor(coverageScore) {
  if (!coverageScore) return 'transparent'
  if (coverageScore >= 98) return '#22c55e'
  if (coverageScore >= 95) return '#facc15'

  return '#ef4444'
}
