import { Routes, Route, useLocation } from 'react-router-dom';
import { useEffect } from 'react';
import { scores } from './utils/metrics';
import { healthScore } from './utils/health-score';
import sampleFeatures from './data/sample_features';
import Dashboard from './pages/Dashboard';
import Feature from './pages/Feature';

export default function App() {
  const features = window.FEATURES || sampleFeatures;

  const { cyclomaticComplexityScores, encapsulationScores, testCoverageScores } = scores({ features })
  const annotatedFeatures = Object.entries(features).reduce((accumulatingFeatures, [featureName, feature]) => {
    const cyclomaticComplexity = cyclomaticComplexityScores[featureName]
    const encapsulation = encapsulationScores[featureName]
    const testCoverage = testCoverageScores[featureName]

    return {
      ...accumulatingFeatures,
      [featureName]: {
        ...feature,
        scores: {
          encapsulation,
          health: healthScore({ cyclomaticComplexity, encapsulation, testCoverage }),
          cyclomaticComplexity,
          testCoverage,
        }
      }
    }
  }, {})

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
