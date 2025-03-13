import { rm } from 'fs/promises';

export default function inlinePlugin() {
  return {
    name: 'inline-bundle',
    apply: 'build',

    transformIndexHtml: {
      enforce: 'post',
      async transform(html, ctx) {
        if (!ctx.bundle) return html;

        let jsCode = '';
        let cssCode = '';

        for (const [fileName, chunk] of Object.entries(ctx.bundle)) {
          if (chunk.type === 'chunk' && chunk.isEntry) {
            jsCode = chunk.code;
          } else if (chunk.type === 'asset' && fileName.endsWith('.css')) {
            cssCode = chunk.source;
          }
        }

        return `
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="UTF-8" />
              <meta name="viewport" content="width=device-width, initial-scale=1.0" />
              <title>Feature Map Dashboard</title>
              <style>${cssCode}</style>
              <!--
                Running the \`bin/featuremap docs\` command within a particular codebase will generate a \`feature-map-config.js\` file in the \`.featuremap/docs/\` directory and
                load the \`window.FEATURE_MAP_CONFIG\` global variable with the information necessary to populate feature data in the documentation site.
              -->
              <script src="./feature-map-config.js" type="text/javascript"></script>
            </head>
            <body class="bg-gray-100">
              <div id="root"></div>
              <script>${jsCode}</script>
            </body>
          </html>`;
      },
    },

    // This hook runs after the bundle has been written to disk
    async closeBundle() {
      try {
        // Remove the assets directory and all its contents
        await rm('../lib/feature_map/private/docs/assets', { recursive: true, force: true });
        // eslint-disable-next-line no-undef
        console.log('Successfully removed assets from documentation site assets directory');
      } catch (error) {
        // eslint-disable-next-line no-undef
        console.error('Error cleaning up assets directory:', error);
      }
    },
  };
}
