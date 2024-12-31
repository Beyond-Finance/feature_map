import React from 'react';
import { Info } from 'lucide-react';
import CircularProgress from './CircularProgress';

const FeatureCard = ({
  children,
  title,
  value,
  suffix = '',
  icon,
  tooltip,
  color,
}) => {
  return (
    <div className="flex flex-col gap-6 px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            {icon}
          </div>
          <span className="flex pl-2">{title}</span>
        </h3>

        <div className="relative flex-shrink-0 group">
          <Info className="size-4 text-gray-400" />
          {tooltip && (
            <div className="absolute whitespace-nowrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2">
              {tooltip}
            </div>
          )}
        </div>
      </div>

      <div className="flex items-center gap-4">
        <CircularProgress
          value={value}
          suffix={suffix}
          color={color}
        />

        <div className="flex flex-col flex-1">
          {children}
        </div>
      </div>
    </div>
  );
};

export default FeatureCard;
