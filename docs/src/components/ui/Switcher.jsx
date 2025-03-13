import React from 'react';
import { Field, Radio, RadioGroup } from '@headlessui/react'

const Switcher = ({ items, selectedItem, onItemSelect, size="sm" }) => {
  return (
    <RadioGroup
      value={selectedItem}
      onChange={onItemSelect}
      className={`inline-flex justify-between items-center rounded-md bg-white text-${size} font-medium text-gray-900 shadow-sm ring-1 ring-gray-300`}
    >
      {items.map((item) => (
        <Field key={item} className="flex h-full first:rounded-l-md last:rounded-r-md overflow-hidden">
          <Radio
            value={item}
            className="cursor-pointer h-full data-[checked]:bg-gray-200 hover:bg-gray-50 flex items-center px-4 shadow-sm">
            {item}
          </Radio>
        </Field>
      ))}
    </RadioGroup>
  )
}

export default Switcher
