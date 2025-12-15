#!/usr/bin/env python3
"""
Script para substituir print() por debugPrint() com proteção kDebugMode
em arquivos Dart do projeto app-plantis.

Uso: python3 scripts/fix_prints.py
"""

import re
import os
from pathlib import Path

def fix_prints_in_file(file_path):
    """Corrige prints em um arquivo Dart"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    lines = content.split('\n')
    new_lines = []
    i = 0
    changes = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Pular prints que já estão dentro de if (kDebugMode)
        if 'if (kDebugMode)' in line:
            # Capturar bloco kDebugMode
            new_lines.append(line)
            i += 1
            indent_level = len(line) - len(line.lstrip())
            
            # Processar bloco dentro do if
            while i < len(lines):
                next_line = lines[i]
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # Se encontrar print dentro do bloco, substituir por debugPrint
                if re.search(r'^\s*print\(', next_line):
                    next_line = next_line.replace('print(', 'debugPrint(')
                    changes += 1
                
                new_lines.append(next_line)
                i += 1
                
                # Sair do bloco quando a indentação diminuir
                if next_indent <= indent_level and next_line.strip() and not next_line.strip().startswith('}'):
                    break
            continue
        
        # Prints soltos (sem proteção) - envolver com if (kDebugMode)
        match = re.match(r'^(\s*)print\(', line)
        if match:
            indent = match.group(1)
            
            # Verificar se é print multi-linha
            if not line.rstrip().endswith(');'):
                # Print multi-linha
                print_lines = [line]
                i += 1
                while i < len(lines) and not lines[i-1].rstrip().endswith(');'):
                    print_lines.append(lines[i])
                    i += 1
                
                # Envolver com kDebugMode
                new_lines.append(f'{indent}if (kDebugMode) {{')
                for pline in print_lines:
                    # Substituir print por debugPrint
                    pline_fixed = pline.replace('print(', 'debugPrint(', 1)
                    new_lines.append(f'{indent}  {pline_fixed.lstrip()}')
                new_lines.append(f'{indent}}}')
                changes += 1
            else:
                # Print de linha única
                new_lines.append(f'{indent}if (kDebugMode) {{')
                line_fixed = line.replace('print(', 'debugPrint(', 1)
                new_lines.append(f'{indent}  {line_fixed.lstrip()}')
                new_lines.append(f'{indent}}}')
                changes += 1
                i += 1
            continue
        
        new_lines.append(line)
        i += 1
    
    if changes > 0:
        new_content = '\n'.join(new_lines)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return changes
    
    return 0

def main():
    """Processa todos os arquivos Dart do projeto"""
    lib_path = Path('lib')
    dart_files = list(lib_path.rglob('*.dart'))
    
    total_changes = 0
    files_changed = 0
    
    for dart_file in dart_files:
        changes = fix_prints_in_file(dart_file)
        if changes > 0:
            total_changes += changes
            files_changed += 1
            print(f'✓ {dart_file}: {changes} prints corrigidos')
    
    print(f'\n✅ Concluído!')
    print(f'   Arquivos modificados: {files_changed}')
    print(f'   Total de prints corrigidos: {total_changes}')

if __name__ == '__main__':
    main()
