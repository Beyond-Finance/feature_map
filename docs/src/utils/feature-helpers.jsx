import React from 'react';

export const MAX_SIZE_THRESHOLD = {
  xl: { loc: 3000, files: 20 }
};

export const featureSizes = {
  xs: 5,
  s: 20,
  m: 70,
  l: 95,
  xl: 100,
}

export const getFeatureSizeColor = (sizeScore) => {
  if (!sizeScore) return { hex: '#f3f4f6', class: 'bg-gray-100' }
  if (sizeScore <= featureSizes.xs) return { hex: '#93c5fd', class: 'bg-blue-300'};
  if (sizeScore <= featureSizes.s) return { hex: '#3b82f6', class: 'bg-blue-500'};
  if (sizeScore <= featureSizes.m) return { hex: '#2563eb', class: 'bg-blue-600' };
  if (sizeScore <= featureSizes.l) return { hex: '#1e40af', class: 'bg-blue-800' };
  return {
    hex: '#1e3a8a',
    class: 'bg-blue-900'
  };
}

export const coverageScores = {
  poor: 95,
  fair: 98,
  good: 100
}

export const getTestCoverageColor = (coverageScore) => {
  if (!coverageScore) return { hex: 'transparent', class: 'bg-transparent' }
  if (coverageScore <= coverageScores.poor) return { hex: '#ef4444', class: 'bg-red-500' };
  if (coverageScore <= coverageScores.fair) return { hex: '#eab308', class: 'bg-yellow-500' };
  return {
    hex: '#22c55e',
    class: 'bg-green-500'
  };
}

export const getTestCoverageLabel = (coverageScore) => {
  if (coverageScore <= coverageScores.poor) return 'poor';
  if (coverageScore <= coverageScores.fair) return 'fair';
  return 'good';
}

export const getSizeLabel = (sizeScore) => {
  if (sizeScore <= featureSizes.xs) return 'xs';
  if (sizeScore <= featureSizes.s) return 's';
  if (sizeScore <= featureSizes.m) return 'm';
  if (sizeScore <= featureSizes.l) return 'l';
  return 'xl';
}

export const getSizeColor = (sizeScore) => {
  if (sizeScore <= featureSizes.xs) return 'bg-green-100 text-green-800';
  if (sizeScore <= featureSizes.s) return 'bg-blue-100 text-blue-800';
  if (sizeScore <= featureSizes.m) return 'bg-violet-100 text-violet-800';
  if (sizeScore <= featureSizes.l) return 'bg-amber-100 text-amber-800';
  return 'bg-red-100 text-red-800';
}

export const getFilledPills = (sizeScore) => {
  if (sizeScore <= featureSizes.xs) return 1;
  if (sizeScore <= featureSizes.s) return 2;
  if (sizeScore <= featureSizes.m) return 3;
  if (sizeScore <= featureSizes.l) return 4;
  return 5;
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
