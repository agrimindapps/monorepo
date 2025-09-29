#!/usr/bin/env python3
import re
import os
import glob

def fix_constructor_parameters(file_path):
    """Fix final_not_initialized_constructor errors in a Dart file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Pattern 1: required parameterName, -> required this.parameterName,
        content = re.sub(r'(\s+)required\s+([a-zA-Z_][a-zA-Z0-9_]*),', r'\1required this.\2,', content)
        
        # Pattern 2: required parameterName) -> required this.parameterName)
        content = re.sub(r'(\s+)required\s+([a-zA-Z_][a-zA-Z0-9_]*)\)', r'\1required this.\2)', content)
        
        # Pattern 3: required parameterName$ (end of line) -> required this.parameterName
        content = re.sub(r'(\s+)required\s+([a-zA-Z_][a-zA-Z0-9_]*)$', r'\1required this.\2', content, flags=re.MULTILINE)
        
        # Pattern 4: Constructor(parameterName) -> Constructor(this.parameterName)
        content = re.sub(r'(\s+)([a-zA-Z_][a-zA-Z0-9_]*)\(([a-zA-Z_][a-zA-Z0-9_]*)\)', r'\1\2(this.\3)', content)
        
        # Pattern 5: Single parameter without required keyword
        # Example: parameterName, -> this.parameterName,
        content = re.sub(r'(\s+)([a-zA-Z_][a-zA-Z0-9_]*),(\s*//.*)?$', r'\1this.\2,\3', content, flags=re.MULTILINE)
        
        # Only write if content changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            return True
        else:
            print(f"No changes needed: {file_path}")
            return False
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    # Find all Dart files in calculators module
    dart_files = glob.glob('/Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-agrihurbi/lib/features/calculators/**/*.dart', recursive=True)
    
    fixed_count = 0
    total_count = len(dart_files)
    
    print(f"Processing {total_count} Dart files...")
    
    for file_path in dart_files:
        if fix_constructor_parameters(file_path):
            fixed_count += 1
    
    print(f"\nProcessing complete!")
    print(f"Files processed: {total_count}")
    print(f"Files fixed: {fixed_count}")

if __name__ == "__main__":
    main()