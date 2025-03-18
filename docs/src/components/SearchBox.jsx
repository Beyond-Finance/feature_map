export default function SearchBox({ onSearch }) {
  return (
    <div className="relative w-full md:w-[26rem] rounded-md">
      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          className="w-5 h-5 text-gray-400"
        >
          <path
            fillRule="evenodd"
            d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
            clipRule="evenodd"
          />
        </svg>
      </div>

      <input
        type="text"
        className="block w-full pl-10 px-3 py-3 text-sm font-medium bg-white text-gray-900 shadow-xs rounded-md outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline-2 focus:-outline-offset-2 focus:outline-blue-600 w-"
        placeholder="Search features..."
        onChange={(e) => onSearch(e.target.value)}
      />
    </div>
  );
}
