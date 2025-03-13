// NOTE:  This sample_config is generated as part of `bin/docs`
import { sampleConfig } from '../../sample_config';
import sampleProjectConfig from '../../../.feature_map/config.yml';

const defaultConfig = {
  ...sampleConfig,
  project: sampleProjectConfig,
  environment: { git_ref: 'main' },
};
export const config = window.FEATURE_MAP_CONFIG || defaultConfig;
