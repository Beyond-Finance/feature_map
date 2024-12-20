import React, { useEffect, useRef } from 'react';
import * as d3 from 'd3';
import { FolderTree } from 'lucide-react';

const FeatureTreemap = ({ files }) => {
  const containerRef = useRef(null);
  const svgRef = useRef(null);

  useEffect(() => {
    if (!files?.length || !containerRef.current) return;

    // Get container dimensions
    const container = containerRef.current;
    const width = container.clientWidth;
    const height = container.clientHeight;

    // Clear previous content
    const svgElement = d3.select(svgRef.current);
    svgElement.selectAll("*").remove();

    // Set up SVG with viewBox for proper scaling
    svgElement
      .attr("viewBox", `0 0 ${width} ${height}`)
      .attr("preserveAspectRatio", "xMidYMid meet");

    const margin = { top: 10, right: 10, bottom: 10, left: 10 };

    const buildHierarchy = () => {
      const root = {
        name: "root",
        children: {}
      };

      files.forEach(path => {
        const parts = path.split('/').filter(Boolean);
        let current = root;

        parts.forEach((part, i) => {
          if (i === parts.length - 1) {
            if (!current.children[part]) {
              current.children[part] = {
                name: part,
                value: 1,
                type: 'file'
              };
            }
          } else {
            if (!current.children[part]) {
              current.children[part] = {
                name: part,
                children: {},
                type: 'directory'
              };
            }
            current = current.children[part];
          }
        });
      });

      const convert = (node) => {
        if (node.type === 'file') {
          return node;
        }
        return {
          ...node,
          children: Object.values(node.children).map(convert)
        };
      };

      return convert(root);
    };

    const getColor = (d) => {
      if (d.data.type === 'file') return '#eff6ff'; // Light gray for files
      if (d.data.name === 'src') return '#3b82f6';  // Blue for src
      if (d.depth === 1) return '#3b82f6';          // Lighter blue for feature level
      if (d.depth === 2) return '#60a5fa';          // Lighter blue for feature level
      return '#93c5fd';                             // Lightest blue for inner directories
    };

    const treemap = d3.treemap()
      .size([width, height])
      .paddingOuter(8)
      .paddingTop(24)
      .paddingInner(4)
      .round(true);

    const hierarchy = d3.hierarchy(buildHierarchy())
      .sum(d => d.value || 0)
      .sort((a, b) => b.value - a.value);

    treemap(hierarchy);

    const svg = svgElement
      .append("g")

    const validNodes = hierarchy.descendants().filter(d =>
      d.data.name !== 'root' && (d.data.type === 'file' || d.children?.length > 0)
    );

    const cell = svg
      .selectAll("g")
      .data(validNodes)
      .join("g")
      .attr("transform", d => `translate(${d.x0},${d.y0})`);

    cell.append("rect")
      .attr("width", d => d.x1 - d.x0)
      .attr("height", d => d.y1 - d.y0)
      .attr("fill", getColor)
      .attr("stroke", d => d.data.type === 'file' ? '#eff6ff' : 'transparent')
      .attr("stroke-width", d => d.data.type === 'file' ? 1 : 2)
      .attr("rx", 2)
      .attr("ry", 2);

    cell.filter(d => d.data.type === 'directory')
      .append("text")
      .attr("x", 4)
      .attr("y", 16)
      .attr("fill", "#37474f")
      // .attr("fill", "#fff")
      .attr("font-weight", 600)
      .attr("font-size", "10px")
      .text(d => {
        const width = d.x1 - d.x0;
        const name = d.data.name;
        if (width < 40) return '';
        return name.length > 12 ? name.slice(0, 10) + '...' : name;
      });

    cell.filter(d => d.data.type === 'file')
      .append("text")
      .attr("x", d => (d.x1 - d.x0) / 2)
      .attr("y", d => (d.y1 - d.y0) / 2)
      .attr("text-anchor", "middle")
      .attr("dominant-baseline", "middle")
      .attr("fill", "#666666")
      .attr("font-size", "9px")
      .text(d => {
        const width = d.x1 - d.x0;
        const height = d.y1 - d.y0;
        if (width < 40 || height < 25) return '';
        const name = d.data.name;
        return name.length > 20 ? name.slice(0, 10) + '...' : name;
      });

    // Add resize handler
    const handleResize = () => {
      const newWidth = container.clientWidth;
      const newHeight = container.clientHeight;

      svgElement.attr("viewBox", `0 0 ${newWidth} ${newHeight}`);

      treemap.size([
        newWidth - margin.left - margin.right,
        newHeight - margin.top - margin.bottom
      ]);

      treemap(hierarchy);

      cell.attr("transform", d => `translate(${d.x0},${d.y0})`);

      cell.select("rect")
        .attr("width", d => d.x1 - d.x0)
        .attr("height", d => d.y1 - d.y0);

      cell.select("text")
        .attr("x", d => {
          if (d.data.type === 'file') {
            return (d.x1 - d.x0) / 2;
          }
          return 4;
        })
        .attr("y", d => {
          if (d.data.type === 'file') {
            return (d.y1 - d.y0) / 2;
          }
          return 16;
        })
        .text(d => {
          const width = d.x1 - d.x0;
          const height = d.y1 - d.y0;
          const name = d.data.name;
          if (d.data.type === 'file') {
            if (width < 40 || height < 25) return '';
            return name.length > 12 ? name.slice(0, 10) + '...' : name;
          } else {
            if (width < 40) return '';
            return name.length > 12 ? name.slice(0, 10) + '...' : name;
          }
        });
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, [files]);

  return (
    <div className="flex flex-col h-full -mt-2 py-2 px-2">
      <div className="flex-1 relative min-h-0" ref={containerRef}>
        <svg
          ref={svgRef}
          className="absolute inset-0 w-full h-full"
        />
      </div>
    </div>
  );
};

export default FeatureTreemap;
