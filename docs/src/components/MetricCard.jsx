export default function MetricCard({ title, value, icon, tooltip }) {
  return (
    <li className="flex flex-col gap-6 px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
      <div className="flex items-center justify-between">
        <h3 className="flex items-center text-xs font-medium text-gray-600 uppercase">
          <div className="flex-shrink-0 bg-gray-100 rounded-md h-8 w-8 flex items-center justify-center">
            {icon}
          </div>
          <span className="flex pl-2">{title}</span>
        </h3>
        {tooltip && (
          <div className="relative flex-shrink-0 group">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="size-5">
              <path strokeLinecap="round" strokeLinejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
            </svg>
            <div className="absolute whitespace-nowrap bottom-full left-1/2 transform -translate-x-1/2 mb-2 hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2">
              {tooltip}
            </div>
          </div>
        )}
      </div>
      <div className="text-3xl font-bold">{value}</div>
    </li>
  );
}
