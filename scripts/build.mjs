import { cp, mkdir, readdir, rm } from "node:fs/promises";
import { join } from "node:path";

const sourceDirectory = "outputs";
const outputDirectory = "dist";
const supportedExtensions = new Set([".html", ".js", ".png"]);

await rm(outputDirectory, { recursive: true, force: true });
await mkdir(outputDirectory, { recursive: true });

const files = await readdir(sourceDirectory, { withFileTypes: true });
const deploymentFiles = files.filter((file) => {
  if (!file.isFile() || file.name.includes(" - Copy")) {
    return false;
  }

  return supportedExtensions.has(file.name.slice(file.name.lastIndexOf(".")));
});

await Promise.all(
  deploymentFiles.map((file) =>
    cp(join(sourceDirectory, file.name), join(outputDirectory, file.name))
  )
);

console.log(`Built ${deploymentFiles.length} static files in ${outputDirectory}.`);
