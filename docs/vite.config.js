import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import ViteYaml from '@modyfi/vite-plugin-yaml';
import inlinePlugin from './build-plugin'

export default defineConfig({
  plugins: [react(), ViteYaml(), inlinePlugin()],
  build: {
    outDir: '../lib/feature_map/private/docs',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        manualChunks: undefined
      }
    }
  }
})
