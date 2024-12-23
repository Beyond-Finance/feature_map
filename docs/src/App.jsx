import { Routes, Route } from 'react-router-dom';
import sampleFeatures from './data/sample_features';
import Dashboard from './pages/Dashboard';
import Feature from './pages/Feature';

export default function App() {
  const features = window.FEATURES || sampleFeatures;

  return (
    <Routes>
      {/* The empty path '' matches the base URL with just the hash */}
      <Route path="" element={<Dashboard features={features} />} />
      <Route path=":name" element={<Feature features={features} />} />
    </Routes>
  );
}
