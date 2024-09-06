#!/bin/bash

# Install dependencies
npm install

# Transpile TypeScript to JavaScript
npx esbuild src/index.ts --bundle --platform=node --target=node20 --external:aws-sdk --outfile=dist/index.js

