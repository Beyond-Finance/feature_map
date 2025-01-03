import sampleConfig from '../data/sample_config';
import sampleProjectConfig from '../../../.feature_map/config.yml'

const defaultConfig = { ...sampleConfig, project: sampleProjectConfig, environment: { git_ref: 'main' } }
export const config = window.FEATURE_MAP_CONFIG || defaultConfig
