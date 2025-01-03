import React, { useState, useMemo } from 'react';
import { ChevronRight, ChevronDown, Folder, FileCode, List, FolderTree } from 'lucide-react';
import { config } from '../utils/config'

const FileExplorer = ({ files }) => {
  const { project, environment } = config;
  const baseUrl = `${project.repository.url}/blob/${environment.git_ref}`

  const initialExpandedDirs = useMemo(() => {
    const dirs = new Set();
    files.forEach(filePath => {
      const parts = filePath.split('/');
      let currentPath = '';

      parts.slice(0, -1).forEach(part => {
        currentPath = currentPath ? `${currentPath}/${part}` : part;
        dirs.add(currentPath);
      });
    });
    return dirs;
  }, [files]);
  const [viewMode, setViewMode] = useState('list'); // 'list' or 'tree'
  const [expandedDirs, setExpandedDirs] = useState(initialExpandedDirs);
  const [sortConfig, setSortConfig] = useState({
    key: null,
    direction: 'asc'
  });

  const fileTree = useMemo(() => {
    const tree = {};

    files.forEach(filePath => {
      const parts = filePath.split('/');
      let current = tree;

      parts.forEach((part, index) => {
        if (index === parts.length - 1) {
          current[part] = { type: 'file', path: filePath };
        } else {
          current[part] = current[part] || { type: 'directory', children: {} };
          current = current[part].children;
        }
      });
    });

    return tree;
  }, [files]);


  const sortedFiles = useMemo(() => {
    return [...files].sort((a, b) => {
      if (!sortConfig.key) return 0;
      if (a < b) return sortConfig.direction === 'asc' ? -1 : 1;
      if (a > b) return sortConfig.direction === 'asc' ? 1 : -1;
      return 0;
    });
  }, [files, sortConfig]);

  const toggleDir = (path) => {
    setExpandedDirs(prev => {
      const next = new Set(prev);
      if (next.has(path)) {
        next.delete(path);
      } else {
        next.add(path);
      }
      return next;
    });
  };

  const requestSort = (key) => {
    setSortConfig((prevConfig) => ({
      key,
      direction: prevConfig.key === key && prevConfig.direction === 'asc' ? 'desc' : 'asc',
    }));
  };

  const renderTree = (node, path = '', level = 0) => {
    if (!node) return null;

    return Object.entries(node).map(([name, item]) => {
      const fullPath = path ? `${path}/${name}` : name;
      const isExpanded = expandedDirs.has(fullPath);

      if (item.type === 'directory') {
        return (
          <React.Fragment key={fullPath}>
            <tr className="hover:bg-gray-50">
              <td className="px-4 py-2 text-sm text-gray-900">
                <button
                  onClick={() => toggleDir(fullPath)}
                  className="flex items-center w-full group"
                  style={{ paddingLeft: `${level * 16}px` }}
                >
                  {isExpanded ? (
                    <ChevronDown className="size-4 text-gray-400 mr-1 flex-shrink-0" />
                  ) : (
                    <ChevronRight className="size-4 text-gray-400 mr-1 flex-shrink-0" />
                  )}
                  <Folder className="size-4 text-gray-400 mr-2 flex-shrink-0" />
                  <span className="font-medium text-gray-600 group-hover:text-gray-900">
                    {name}
                  </span>
                </button>
              </td>
            </tr>
            {isExpanded && renderTree(item.children, fullPath, level + 1)}
          </React.Fragment>
        );
      }

      return (
        <tr key={fullPath} className="">
          <td className="px-4 py-2 text-sm text-gray-900">
            <div
              className="flex items-center"
              style={{ paddingLeft: `${(level * 16) + 20}px` }}
            >
              <FileCode className="size-4 text-gray-400 mr-2 flex-shrink-0" />
              <span className="truncate">{name}</span>
            </div>
          </td>
        </tr>
      );
    });
  };

  const SortHeader = ({ title, sortKey, className = "" }) => (
    <th
      scope="col"
      className={`px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider cursor-pointer ${className}`}
      onClick={() => requestSort(sortKey)}
    >
      <div className="flex items-center gap-x-2 group">
        {title}
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="size-4 text-gray-400 group-hover:text-gray-600">
          <path strokeLinecap="round" strokeLinejoin="round" d="M3 7.5 7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5" />
        </svg>
      </div>
    </th>
  );

  return (
    <div className="bg-white rounded-lg border border-gray-200">
      <div className="overflow-hidden rounded-lg">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <SortHeader
                title={viewMode === 'list' ? "File Path" : "Name"}
                sortKey="path"
              />
              <th
                scope="col"
                className="px-4 py-3 text-center text-xs font-medium text-gray-800 uppercase tracking-wider"
              >
                <div className="flex items-center justify-end gap-2">
                  <button
                    onClick={() => setViewMode('list')}
                    className={`p-1 rounded ${
                      viewMode === 'list'
                        ? 'text-blue-600 bg-blue-100'
                        : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
                    }`}
                  >
                    <List className="size-4" />
                  </button>
                  <button
                    onClick={() => setViewMode('tree')}
                    className={`p-1 rounded ${
                      viewMode === 'tree'
                        ? 'text-blue-600 bg-blue-100'
                        : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
                    }`}
                  >
                    <FolderTree className="size-4" />
                  </button>
                </div>
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {viewMode === 'list' ? (
              sortedFiles.map((file) => (
                <tr key={file} className="">
                  <td className="px-4 py-3 text-sm font-medium text-gray-900 flex-1">
                    <div className="flex items-center">
                      <FileCode className="size-4 text-gray-400 mr-2 flex-shrink-0" />
                        <a href={`${baseUrl}/${file}`} className="truncate underline" target="_blank">
                          {file}
                        </a>
                    </div>
                  </td>
                </tr>
              ))
            ) : (
              renderTree(fileTree)
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default FileExplorer;
