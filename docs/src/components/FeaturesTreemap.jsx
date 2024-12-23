import React, { useState } from 'react';
import { Treemap, ResponsiveContainer } from 'recharts';
import { Shapes, FileCode, GitCompareArrows } from 'lucide-react';

const FeaturesTreemap = ({ data = {} }) => {
  const [activeMetric, setActiveMetric] = useState('lines_of_code');

  const metrics = [
    { id: 'lines_of_code', label: 'Lines of Code', icon: FileCode },
    { id: 'abc_size', label: 'ABC Size', icon: Shapes },
    { id: 'cyclomatic_complexity', label: 'Complexity', icon: GitCompareArrows }
  ];

  const categoryThresholds = {
    high: 0.67,
    medium: 0.33,
  };

  const categoryColors = {
    high: '#EF4444',
    medium: '#F59E0B',
    low: '#10B981',
  };

  const transformData = () => ({
    children: Object.entries(data || {}).map(([name, value]) => ({
      name,
      lines_of_code: value?.metrics?.lines_of_code || 0,
      abc_size: value?.metrics?.abc_size || 0,
      cyclomatic_complexity: value?.metrics?.cyclomatic_complexity || 0,
      teams: value?.teams || []
    }))
  });

  const getCategory = (value, data) => {
    if (!data?.children?.length) return 'medium';
    const allValues = data.children.map(item => item[activeMetric] || 0);
    const max = Math.max(...allValues);
    const min = Math.min(...allValues);
    const range = max - min;
    const normalizedValue = range ? (value - min) / range : 0.5;

    if (normalizedValue >= categoryThresholds.high) return 'high';
    if (normalizedValue >= categoryThresholds.medium) return 'medium';
    return 'low';
  };

  const getCategoryLabel = (category) => {
    switch (category) {
      case 'high': return 'High';
      case 'medium': return 'Medium';
      case 'low': return 'Low';
      default: return '';
    }
  };

  const calculateTotal = () => {
    if (!data) return 0;
    return Object.values(data).reduce((sum, feature) =>
      sum + (feature?.metrics?.[activeMetric] || 0), 0);
  };

  const getFontSize = (width, height) => {
    const area = width * height;
    return Math.min(Math.max(Math.sqrt(area) / 10, 8), 12);
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
    <div>
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="px-3 py-1 bg-gray-100 rounded-md">
            <span className="text-sm text-gray-600 font-medium">
              Total {metrics.find(m => m.id === activeMetric)?.label}: {calculateTotal().toLocaleString()}
            </span>
          </div>

          <div className="flex items-center gap-2">
            {Object.entries(categoryColors).map(([category, color]) => (
              <div key={category} className="flex items-center">
                <div
                  className="w-3 h-3 rounded-sm mr-1"
                  style={{ backgroundColor: color }}
                />
                <span className="text-xs text-gray-600">
                  {getCategoryLabel(category)}
                </span>
              </div>
            ))}
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
            isAnimationActive={false}
            content={({ x, y, width, height, name, value, root }) => {
              if (!width || !height) return null;

              const showText = width > 40 && height > 30;
              const category = getCategory(value, root);
              const backgroundColor = categoryColors[category];

              if (!showText) return (
                <rect
                  x={x}
                  y={y}
                  width={width}
                  height={height}
                  style={{
                    fill: backgroundColor,
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

              return (
                <g>
                  <rect
                    x={x}
                    y={y}
                    width={width}
                    height={height}
                    style={{
                      fill: backgroundColor,
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
                      fill="#fff"
                      fontSize={fontSize}
                      style={{
                        fontWeight: 500,
                        textTransform: 'uppercase',
                        textShadow: '1px 1px 2px rgba(0,0,0,0.5)'
                      }}
                    >
                      {line}
                    </text>
                  ))}
                  <text
                    x={x + width / 2}
                    y={startY + totalTextHeight + 4}
                    textAnchor="middle"
                    fill="#fff"
                    fontSize={fontSize * 0.9}
                    fontWeight={500}
                    style={{
                      textShadow: '1px 1px 2px rgba(0,0,0,0.5)'
                    }}
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

export default FeaturesTreemap;
