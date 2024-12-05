export default function FeatureTable({ features }) {
  return (
    <div className="mt-8 flow-root">
      <div className="overflow-x-auto sm:-mx-6 lg:-mx-8 border border-gray-200 rounded-lg sm:border-none sm:rounded-none">
        <div className="inline-block min-w-full sm:py-0.5 align-middle sm:px-6 lg:px-8">
          <div className="overflow-hidden shadow ring-1 ring-black/5 sm:rounded-lg">
            <table className="table-auto w-full divide-y divide-gray-300">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider">Feature</th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider">ABC Size</th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider">Lines of code</th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider">Complexity</th>
                  <th scope="col" className="px-4 py-3 text-left text-xs font-medium text-gray-800 uppercase tracking-wider">File Count</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 bg-white">
                {Object.entries(features).map(([name, data]) => (
                  <tr key={name}>
                    <td className="whitespace-nowrap py-5 px-4 text-sm font-medium text-gray-800">{name}</td>
                    <td className="whitespace-nowrap py-5 px-4 text-sm text-gray-700">{data.metrics.abc_size}</td>
                    <td className="whitespace-nowrap py-5 px-4 text-sm text-gray-700">{data.metrics.lines_of_code}</td>
                    <td className="whitespace-nowrap py-5 px-4 text-sm text-gray-700">{data.metrics.cyclomatic_complexity}</td>
                    <td className="whitespace-nowrap py-5 px-4 text-sm text-gray-700">{data.assignments.files.length}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
