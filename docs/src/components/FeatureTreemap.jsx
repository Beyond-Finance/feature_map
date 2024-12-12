import React, { useState } from 'react';
import { Treemap, ResponsiveContainer } from 'recharts';
import { GitCommit, Activity, BarChart2 } from 'lucide-react';

const FeatureTreemap = ({ data = {} }) => {
  const [activeMetric, setActiveMetric] = useState('lines_of_code');

  const metrics = [
    { id: 'lines_of_code', label: 'Lines of Code', icon: GitCommit },
    { id: 'abc_size', label: 'ABC Size', icon: Activity },
    { id: 'cyclomatic_complexity', label: 'Complexity', icon: BarChart2 }
  ];

  const transformData = () => ({
    children: Object.entries(data || {}).map(([name, value]) => ({
      name,
      lines_of_code: value?.metrics?.lines_of_code || 0,
      abc_size: value?.metrics?.abc_size || 0,
      cyclomatic_complexity: value?.metrics?.cyclomatic_complexity || 0,
      teams: value?.teams || []
    }))
  });

  const getColor = (value, data) => {
    if (!data?.children?.length) return 'hsl(210, 90%, 65%)';
    const allValues = data.children.map(item => item[activeMetric] || 0);
    const max = Math.max(...allValues);
    const min = Math.min(...allValues);
    const range = max - min;
    const normalizedValue = range ? (value - min) / range : 0.5;

    // Adjusted range to be between 65% and 25% lightness for better contrast
    return `hsl(210, 90%, ${65 - (normalizedValue * 40)}%)`;
  };

  const calculateTotal = () => {
    if (!data) return 0;
    return Object.values(data).reduce((sum, feature) =>
      sum + (feature?.metrics?.[activeMetric] || 0), 0);
  };

  const getFontSize = (width, height) => {
    const area = width * height;
    return Math.min(Math.max(Math.sqrt(area) / 10, 8), 10);
  };

  const getTextColor = (value, root) => {
    const allValues = root.children.map(item => item[activeMetric] || 0);
    const max = Math.max(...allValues);
    const min = Math.min(...allValues);
    const range = max - min;
    const normalizedValue = range ? (value - min) / range : 0.5;

    // Return white text for darker backgrounds (higher values)
    // and black text for lighter backgrounds (lower values)
    return normalizedValue > 0.5 ? '#fff' : '#000';
  };

  const splitText = (text = '', maxLength = 12) => {
    if (!text) return [''];
    const words = text.split(' ');
    if (words.length === 1) return [text];

    const lines = [];
    let currentLine = words[0];

    for (let i = 1; i < words.length; i++) {
      if ((currentLine + ' ' + words[i]).length <= maxLength) {
        currentLine += ' ' + words[i];
      } else {
        lines.push(currentLine);
        currentLine = words[i];
      }
    }
    lines.push(currentLine);
    return lines;
  };

  const treeMapData = transformData().children;
  if (!treeMapData.length) return null;

  return (
    <div className="bg-white rounded-lg shadow-sm p-4">
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="px-3 py-1 bg-gray-100 rounded-md">
            <span className="text-sm text-gray-600 font-medium">
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
                activeMetric === id ? 'bg-blue-100 text-blue-600' : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <Icon className="w-4 h-4 mr-2" />
              {label}
            </button>
          ))}
        </div>
      </div>

      <div className="h-[550px]">
        <ResponsiveContainer width="100%" height="100%">
          <Treemap
            data={treeMapData}
            dataKey={activeMetric}
            stroke="#fff"
            content={({ x, y, width, height, name, value, root }) => {
              if (!width || !height) return null;

              const showText = width > 40 && height > 30;
              if (!showText) return (
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
              );

              const fontSize = getFontSize(width, height);
              const lines = splitText(name);
              const lineHeight = fontSize * 1.2;
              const totalTextHeight = lines.length * lineHeight;
              const startY = y + (height - totalTextHeight) / 2;
              const textColor = getTextColor(value, root);

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
                  {lines.map((line, i) => (
                    <text
                      key={i}
                      x={x + width / 2}
                      y={startY + (i * lineHeight)}
                      textAnchor="middle"
                      fill={textColor}
                      fontSize={fontSize}
                      style={{
                        fontWeight: 500,
                        textTransform: 'uppercase'
                      }}
                    >
                      {line}
                    </text>
                  ))}
                  <text
                    x={x + width / 2}
                    y={startY + totalTextHeight + 4}
                    textAnchor="middle"
                    fill={textColor}
                    fontSize={fontSize * 0.9}
                    fontWeight={500}
                  >
                    {value.toLocaleString()}
                  </text>
                </g>
              );
            }}
          />
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default FeatureTreemap;
