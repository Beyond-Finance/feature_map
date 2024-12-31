import React from 'react';

const CircularProgress = ({
  value,
  suffix = '',
  color = '#ef4444',
}) => {
  const strokeColor = value === 0 ? 'transparent' : color;

  return (
    <div className="relative h-20 w-20">
      <svg className="h-full w-full -rotate-90" viewBox="0 0 36 36">
        <path
          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
          fill="none"
          stroke="#eee"
          strokeWidth="2"
        />
        <path
          d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
          fill="none"
          stroke={strokeColor}
          strokeWidth="2"
          strokeDasharray={`${value}, 100`}
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        <span className="text-2xl font-bold">{Math.round(value)}</span>
        <span className="text-sm">{suffix}</span>
      </div>
    </div>
  );
};

export default CircularProgress;
