import React from 'react';
import { Treemap, ResponsiveContainer } from 'recharts';
import { Users } from 'lucide-react';

const TreemapCell = ({ x, y, width, height, name, value }) => {
  if (!width || !height) return null;

  const showText = width > 30 && height > 30;
  const textClass = width < 80 ? 'text-[10px]' : 'text-xs';

  return (
    <g>
      <rect
        x={x}
        y={y}
        width={width}
        height={height}
        fill={'#3b82f6'}
        style={{
          strokeWidth: 2,
          stroke: '#fff'
        }}
        role="img"
        aria-label={`${name}: ${value} features`}
      />
      <foreignObject x={x} y={y} width={width} height={height}>
        {showText && (
          <div className="h-full w-full flex flex-col items-center justify-center text-white pointer-events-none">
            <div
              className={`uppercase leading-tight px-1 break-words text-center font-bold ${textClass}`}
              aria-hidden="true"
            >
              {name}
            </div>
            <div
              className={`mt-0.5 ${width < 100 ? 'text-xs' : 'text-sm'}`}
              aria-hidden="true"
            >
              {value} {value === 1 ? 'Feature' : 'Features'}
            </div>
          </div>
        )}
      </foreignObject>
    </g>
  );
};

const transformData = (data) => {
  const teamMap = {};

  Object.values(data).forEach(featureData => {
    const teams = featureData?.assignments?.teams || [];
    teams.forEach(team => {
      if (!teamMap[team]) {
        teamMap[team] = {
          name: team,
          value: 0
        };
      }
      teamMap[team].value += 1;
    });
  });

  return {
    children: Object.values(teamMap)
  };
};

const FeaturesTreemap = ({ data = {} }) => {
  const treeMapData = transformData(data);

  if (!treeMapData.children.length) {
    return (
      <div className="h-[400px] flex items-center justify-center text-gray-500">
        No team data available
      </div>
    );
  }

  const totalFeatures = treeMapData.children.reduce((sum, team) => sum + team.value, 0);

  return (
    <div className="relative">
      <div className="mb-4 flex items-center justify-between" role="heading" aria-level="2">
        <div className="flex items-center space-x-2">
          <Users className="w-5 h-5 text-gray-600" aria-hidden="true" />
          <span className="text-sm text-gray-600 font-medium">
            Teams: {treeMapData.children.length} | Total Features: {totalFeatures}
          </span>
        </div>
      </div>

      <div className="h-[400px]" role="img" aria-label="Team features distribution treemap">
        <ResponsiveContainer width="100%" height="100%">
          <Treemap
            data={treeMapData.children}
            dataKey="value"
            isAnimationActive={false}
            content={TreemapCell}
          />
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default FeaturesTreemap;
