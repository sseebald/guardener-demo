// Minimal build step: inline the app shell into dist/.
// Deliberately dependency-free so the demo image builds without a registry round trip.

import { mkdir, writeFile, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const dist = join(here, '..', 'dist');

const app = await readFile(join(here, 'app.js'), 'utf8');

const html = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Northwind Console</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module">
${app}
    </script>
  </body>
</html>
`;

await mkdir(dist, { recursive: true });
await writeFile(join(dist, 'index.html'), html, 'utf8');

console.log('built dist/index.html');
