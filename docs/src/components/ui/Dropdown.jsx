import React from 'react';
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/react';
import { ChevronDown } from 'lucide-react';

const Dropdown = ({ items, selectedItem, onItemSelect, size = 'sm' }) => {
  return (
    <div className="relative h-full">
      <Menu>
        <MenuButton
          className={`inline-flex h-full w-48 justify-between items-center gap-x-1.5 rounded-md bg-white px-3 text-${size} font-medium text-gray-900 shadow-sm ring-1 ring-gray-300 hover:bg-gray-50`}
        >
          {selectedItem}
          <ChevronDown className="size-4 text-gray-400" aria-hidden="true" />
        </MenuButton>

        <MenuItems className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none">
          <div className="py-1">
            {items.map((item) => (
              <MenuItem key={item}>
                <button
                  onClick={() => onItemSelect(item)}
                  className={`block w-full px-4 py-2 text-left text-${size} data-[focus]:bg-gray-100 data-[focus]:text-gray-900 text-gray-700`}
                >
                  {item}
                </button>
              </MenuItem>
            ))}
          </div>
        </MenuItems>
      </Menu>
    </div>
  );
};

export default Dropdown;
