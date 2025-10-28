#!/bin/bash

cd "$(dirname "$0")"

# Process each template file
for file in $(find lib -name "*.template" -type f); do
  output="${file%.template}"
  sed -e 's/{{APP_NAME}}/app_nebulalist/g' \
      -e 's/{{BUNDLE_ID}}/br.com.agrimind.nebulalist/g' \
      -e 's/{{APP_DISPLAY_NAME}}/NebulaList/g' \
      "$file" > "$output"
  rm "$file"
  echo "Processed: $file -> $output"
done

echo "All template files processed successfully"
