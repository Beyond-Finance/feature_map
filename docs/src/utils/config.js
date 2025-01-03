import sampleConfig from '../data/sample_config';
import sampleProjectConfig from '../../../.feature_map/config.yml'

export const getConfig = () => {
  return window.FEATURE_MAP_CONFIG || { ...sampleConfig, project: sampleProjectConfig, environment: { commit_sha: 'main' } }
}
