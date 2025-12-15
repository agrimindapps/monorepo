#!/usr/bin/env python3
"""
Script para corrigir throws de strings/objetos que não são Exception/Error.
Converte: throw _getErrorMessage(failure) -> throw Exception(_getErrorMessage(failure))
"""

import re
from pathlib import Path

def fix_throws_in_file(file_path):
    """Corrige throws em um arquivo Dart"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Padrão: throw _getErrorMessage(...)
    # Substituir por: throw Exception(_getErrorMessage(...))
    pattern = r'throw\s+_getErrorMessage\('
    if re.search(pattern, content):
        content = re.sub(pattern, 'throw Exception(_getErrorMessage(', content)
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    
    return False

def main():
    """Processa todos os arquivos Dart do projeto"""
    lib_path = Path('lib')
    dart_files = list(lib_path.rglob('*.dart'))
    
    files_changed = 0
    
    for dart_file in dart_files:
        if fix_throws_in_file(dart_file):
            files_changed += 1
            print(f'✓ {dart_file}')
    
    print(f'\n✅ Concluído!')
    print(f'   Arquivos modificados: {files_changed}')

if __name__ == '__main__':
    main()
