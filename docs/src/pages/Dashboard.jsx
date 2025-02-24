import React, { useState, useMemo } from 'react';
import { Users } from 'lucide-react';
import FeatureSizeDataCard from '../components/FeatureSizeDataCard';
import HealthScoreDataCard from '../components/HealthScoreDataCard';
import TestCoverageDataCard from '../components/TestCoverageDataCard';
import FeaturesTable from '../components/FeaturesTable';
import { Dropdown } from '../components/ui';
import SearchBox from '../components/SearchBox';

const Dashboard = ({ features }) => {
  const [selectedTeam, setSelectedTeam] = useState('All Teams');
  const [searchTerm, setSearchTerm] = useState('');

  const teams = useMemo(() => {
    const teamSet = new Set();
    teamSet.add('All Teams');

    Object.values(features).forEach(feature => {
      if (feature.assignments?.teams) {
        feature.assignments.teams.forEach(team => teamSet.add(team));
      }
    });

    return Array.from(teamSet);
  }, [features]);

  const filteredFeatures = useMemo(() => {
    if (selectedTeam === 'All Teams') return features;

    return Object.fromEntries(
      Object.entries(features).filter(([_, data]) =>
        data.assignments?.teams?.includes(selectedTeam)
      )
    );
  }, [features, selectedTeam]);

  const totalFeatures = Object.entries(features).length
  const totalTeams = teams.length - 1 // This array returns 1 extra item to support the All Teams dropdown

  return (
    <div className="h-screen max-w-7xl mx-auto flex flex-col gap-8 p-4 md:p-8">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <Dropdown
          items={teams}
          selectedItem={selectedTeam}
          onItemSelect={setSelectedTeam}
        />
      </div>

      <div>
        <ul className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
            <FeatureSizeDataCard features={filteredFeatures} />
          </li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
            <HealthScoreDataCard features={filteredFeatures} />
          </li>
          <li className="px-4 py-6 border border-gray-200 shadow-sm bg-white rounded-lg">
            <TestCoverageDataCard features={filteredFeatures} />
          </li>
        </ul>
      </div>

      <div className="flex-1 flex flex-col gap-6 h-full overflow-scroll">
        <div className="flex items-center justify-between gap-12">
          <div className="flex items-center gap-2">
            <Users className="w-5 h-5 text-gray-600" aria-hidden="true" />
            <span className="text-sm text-gray-600 font-medium">
              Features: { Object.entries(filteredFeatures).length }
            </span>
          </div>

          <div>
            <SearchBox onSearch={setSearchTerm} />
          </div>
        </div>

        <FeaturesTable
          features={filteredFeatures}
          searchTerm={searchTerm}
          teamContext={selectedTeam !== 'All Teams' ? selectedTeam : null}
        />
      </div>
    </div>
  );
};

export default Dashboard;
