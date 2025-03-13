import React from 'react';
import { Info } from 'lucide-react';
import CircularProgress from './CircularProgress';
import { Tooltip, TooltipButton, TooltipPanel } from '../components/Tooltip';

const FeatureCard = ({ children, title, value, suffix = '', icon, tooltip, color }) => {
  return (
    <div className="flex flex-col gap-6 px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            {icon}
          </div>
          <span className="flex pl-2">{title}</span>
        </h3>

        {tooltip && (
          <Tooltip>
            <TooltipButton>
              <Info className="size-4 text-gray-400" />
            </TooltipButton>

            <TooltipPanel>{tooltip}</TooltipPanel>
          </Tooltip>
        )}
      </div>

      <div className="flex items-center gap-4">
        <CircularProgress value={value} suffix={suffix} color={color} />

        <div className="flex flex-col flex-1">{children}</div>
      </div>
    </div>
  );
};

export default FeatureCard;
