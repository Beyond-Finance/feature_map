import { Routes, Route, useLocation } from 'react-router-dom';
import { useEffect } from 'react';
import sampleFeatures from './data/sample_features';
import Dashboard from './pages/Dashboard';
import Feature from './pages/Feature';

export default function App() {
  const features = window.FEATURES || sampleFeatures;
  const location = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location]);

  return (
    <Routes>
      <Route path="" element={<Dashboard features={features} />} />
      <Route path=":name" element={<Feature features={features} />} />
    </Routes>
  );
}
