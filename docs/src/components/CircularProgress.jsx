import React from 'react';

const CircularProgress = ({
  value,
  suffix = '',
  color = '#ef4444',
  subtext,
  secondaryText
}) => {
  const strokeColor = value === 0 ? 'transparent' : color;

  return (
    <div className="flex items-center gap-4">
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

      <div className="flex flex-col flex-1">
        <div className="text-[10px] text-gray-500">{subtext}</div>
        {secondaryText && (
          <div className="text-[10px] text-gray-500 mt-1">{secondaryText}</div>
        )}
      </div>
    </div>
  );
};

export default CircularProgress;
