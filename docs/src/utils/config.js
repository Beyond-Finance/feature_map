import sampleConfig from '../data/sample_config';

export const getConfig = () => {
  return window.FEATURE_MAP_CONFIG || sampleConfig
}
