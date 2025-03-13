import { Routes, Route, useLocation } from 'react-router-dom';
import { useEffect } from 'react';

import { config } from './utils/config';
import Dashboard from './pages/Dashboard';
import Digest from './pages/Digest';
import Feature from './pages/Feature';
import Layout from './components/Layout';

export default function App() {
  const { features } = config;
  const location = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location]);

  return (
    <Routes>
      <Route element={<Layout />}>
        <Route path="" element={<Dashboard features={features} />} />
        <Route path="digest" element={<Digest features={features} />} />
        <Route path=":name" element={<Feature features={features} />} />
      </Route>
    </Routes>
  );
}
