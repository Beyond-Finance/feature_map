import React, { useState } from 'react';
import { Treemap, ResponsiveContainer } from 'recharts';
import { GitCommit, Activity, BarChart2 } from 'lucide-react';

const FeatureTreemap = ({ data }) => {
  const [activeMetric, setActiveMetric] = useState('lines_of_code');

  const metrics = [
    {
      id: 'lines_of_code',
      label: 'Lines of Code',
      icon: GitCommit
    },
    {
      id: 'abc_size',
      label: 'ABC Size',
      icon: Activity
    },
    {
      id: 'cyclomatic_complexity',
      label: 'Complexity',
      icon: BarChart2
    }
  ];

  const transformData = () => ({
    children: Object.entries(data).map(([name, value]) => ({
      name,
      lines_of_code: value.metrics.lines_of_code,
      abc_size: value.metrics.abc_size,
      cyclomatic_complexity: value.metrics.cyclomatic_complexity,
      teams: value.teams
    }))
  });

  const getTextConfig = (width, height, name = '') => {
    if (!width || !height || width < 50 || height < 40) return { show: false };

    const titleSize = Math.min(width / (name.length || 1) * 0.8, 16);
    const valueSize = Math.min(titleSize * 0.875, 14);

    return {
      show: true,
      titleSize: Math.max(10, titleSize),
      valueSize: Math.max(9, valueSize),
      titleY: height / 2 - 12,
      valueY: height / 2 + 12
    };
  };

  const getColor = (value, data) => {
    if (!data?.children?.length) return 'hsl(210, 90%, 50%)';

    const allValues = data.children.map(item => item[activeMetric]);
    const max = Math.max(...allValues);
    const min = Math.min(...allValues);
    const range = max - min;
    const normalizedValue = range ? (value - min) / range : 0.5;

    return `hsl(210, 90%, ${65 - (normalizedValue * 30)}%)`;
  };

  const calculateTotal = () => (
    Object.values(data).reduce((sum, feature) => sum + feature.metrics[activeMetric], 0)
  );

  return (
    <>
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <h2 className="text-lg font-semibold">Feature Analysis</h2>
          <div className="px-3 py-1 bg-blue-50 rounded-md">
            <span className="text-sm text-blue-700 font-medium">
              Total {metrics.find(m => m.id === activeMetric)?.label}: {calculateTotal().toLocaleString()}
            </span>
          </div>
        </div>

        <div className="flex space-x-2">
          {metrics.map(({ id, label, icon: Icon }) => (
            <button
              key={id}
              onClick={() => setActiveMetric(id)}
              className={`flex items-center px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                activeMetric === id
                  ? 'bg-blue-50 text-blue-600'
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <Icon className="w-4 h-4 mr-2" />
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="h-[600px]">
        <ResponsiveContainer width="100%" height="100%">
          <Treemap
            data={transformData().children}
            dataKey={activeMetric}
            stroke="#fff"
            content={({ x, y, width, height, name, value, root }) => {
              if (!width || !height) return null;
              const displayValue = Number(value).toLocaleString();
              const textConfig = getTextConfig(width, height, name);

              return (
                <g>
                  <rect
                    x={x}
                    y={y}
                    width={width}
                    height={height}
                    style={{
                      fill: getColor(value, root),
                      stroke: '#fff',
                      strokeWidth: 2,
                    }}
                  />
                  {textConfig.show && (
                    <>
                      <text
                        x={x + width / 2}
                        y={y + textConfig.titleY}
                        textAnchor="middle"
                        fill="#fff"
                        fontSize={textConfig.titleSize}
                        style={{
                          fontWeight: 400,
                        }}
                      >
                        {name}
                      </text>
                      <text
                        x={x + width / 2}
                        y={y + textConfig.valueY}
                        textAnchor="middle"
                        fill="#fff"
                        fontSize={textConfig.valueSize}
                        // style={{ textShadow: '1px 1px 3px rgba(0,0,0,0.3)' }}
                      >
                        {displayValue}
                      </text>
                    </>
                  )}
                </g>
              );
            }}
          />
        </ResponsiveContainer>
      </div>
    </>
  );
};

export default FeatureTreemap;
