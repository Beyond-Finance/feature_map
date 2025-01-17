import React from 'react';
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/react';
import { ChevronDown } from 'lucide-react';

const TeamSelector = ({ teams, selectedTeam, onTeamSelect }) => {
  return (
    <Menu>
      <MenuButton className="inline-flex w-48 justify-between items-center gap-x-1.5 rounded-md bg-white px-3 py-3 text-sm font-medium text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
        {selectedTeam}
        <ChevronDown className="size-4 text-gray-400" aria-hidden="true" />
      </MenuButton>

      <MenuItems className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none">
        <div className="py-1">
          {teams.map((team) => (
            <MenuItem key={team}>
              <button
                onClick={() => onTeamSelect(team)}
                className="block w-full px-4 py-2 text-left text-sm data-[focus]:bg-gray-100 data-[focus]:text-gray-900 text-gray-700"
              >
                {team}
              </button>
            </MenuItem>
          ))}
        </div>
      </MenuItems>
    </Menu>
  );
};

export default TeamSelector;
