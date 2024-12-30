import { Routes, Route, useLocation } from 'react-router-dom';
import { useEffect } from 'react';
import { withMetrics } from './utils/metrics';
import { healthScore } from './utils/health-score';
import sampleFeatures from './data/sample_features';
import Dashboard from './pages/Dashboard';
import Feature from './pages/Feature';

export default function App() {
  const features = window.FEATURES || sampleFeatures;

  const metricFeatures = withMetrics({ features })
  const annotatedFeatures = Object.entries(metricFeatures).reduce(
    (accumulatingFeatures, [featureName, feature]) => {
      const health = healthScore({
        cyclomaticComplexity: feature.metrics.cyclomaticComplexity,
        encapsulation: feature.metrics.encapsulation,
        testCoverage: feature.metrics.testCoverage,
      })

      return {
        ...accumulatingFeatures,
        [featureName]: {
          ...feature,
          health,
        }
      }
    },
    {}
  )

  const location = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location]);

  return (
    <Routes>
      <Route path="" element={<Dashboard features={annotatedFeatures} />} />
      <Route path=":name" element={<Feature features={annotatedFeatures} />} />
    </Routes>
  );
}
