#!/usr/bin/env python3
"""
Script de otimização de assets para ReceitaAgro
Objetivo: Reduzir 143MB para ~20MB sem perder qualidade visual

Estratégias:
1. Compressão de imagens para WebP
2. Redimensionamento inteligente (máx 800x600)
3. Remoção de imagens não utilizadas
4. Migração para assets remotos
"""

import os
import sys
import json
import shutil
from pathlib import Path
from PIL import Image, ImageOps
import zipfile
import requests
from datetime import datetime

class AssetOptimizer:
    def __init__(self, app_path):
        self.app_path = Path(app_path)
        self.assets_path = self.app_path / "assets"
        self.images_path = self.assets_path / "imagens" / "bigsize"
        self.database_path = self.assets_path / "database"
        
        # Estatísticas
        self.stats = {
            'original_size': 0,
            'optimized_size': 0,
            'images_processed': 0,
            'images_removed': 0,
            'webp_converted': 0,
            'resized_images': 0,
            'compression_ratio': 0
        }
        
        # Configurações
        self.max_image_size = (800, 600)  # Máximo 800x600px
        self.webp_quality = 85  # 85% qualidade WebP
        self.jpg_quality = 90   # 90% qualidade JPG
        
    def run_optimization(self):
        """Executa todas as otimizações"""
        print("🚀 Iniciando otimização de assets ReceitaAgro")
        print(f"📁 Diretório: {self.app_path}")
        
        # 1. Análise inicial
        self._analyze_current_assets()
        
        # 2. Backup dos assets originais
        self._create_backup()
        
        # 3. Otimização de imagens
        self._optimize_images()
        
        # 4. Compressão de JSONs
        self._optimize_json_database()
        
        # 5. Preparação para assets remotos
        self._prepare_remote_assets()
        
        # 6. Relatório final
        self._generate_report()
        
    def _analyze_current_assets(self):
        """Analisa assets atuais"""
        print("\n📊 Analisando assets atuais...")
        
        total_size = 0
        image_count = 0
        
        # Analisa imagens
        if self.images_path.exists():
            for img_file in self.images_path.glob("*.jpg"):
                size = img_file.stat().st_size
                total_size += size
                image_count += 1
                
        # Analisa database
        if self.database_path.exists():
            for json_file in self.database_path.rglob("*.json"):
                total_size += json_file.stat().st_size
                
        self.stats['original_size'] = total_size
        
        print(f"  📸 Imagens encontradas: {image_count}")
        print(f"  💾 Tamanho total atual: {self._format_size(total_size)}")
        
    def _create_backup(self):
        """Cria backup dos assets originais"""
        backup_path = self.app_path / "assets_backup"
        
        if backup_path.exists():
            print("⚠️  Backup já existe, pulando...")
            return
            
        print("\n💾 Criando backup dos assets...")
        shutil.copytree(self.assets_path, backup_path)
        print(f"  ✅ Backup criado em: {backup_path}")
        
    def _optimize_images(self):
        """Otimiza todas as imagens"""
        print("\n🖼️  Otimizando imagens...")
        
        if not self.images_path.exists():
            print("  ⚠️  Diretório de imagens não encontrado")
            return
            
        # Lista imagens críticas que devem ficar locais
        critical_images = ['a.jpg', 'Nao classificado.jpg']
        
        # Processa cada imagem
        for img_file in self.images_path.glob("*.jpg"):
            try:
                self._process_image(img_file, img_file.name in critical_images)
            except Exception as e:
                print(f"  ❌ Erro ao processar {img_file.name}: {e}")
                
        print(f"  ✅ {self.stats['images_processed']} imagens processadas")
        print(f"  🗜️  {self.stats['webp_converted']} convertidas para WebP")
        print(f"  📏 {self.stats['resized_images']} redimensionadas")
        
    def _process_image(self, img_path, is_critical=False):
        """Processa uma imagem individual"""
        try:
            # Abre imagem
            with Image.open(img_path) as img:
                original_size = img_path.stat().st_size
                
                # Converte para RGB se necessário
                if img.mode in ('RGBA', 'LA', 'P'):
                    img = img.convert('RGB')
                
                # Redimensiona se muito grande
                if img.size[0] > self.max_image_size[0] or img.size[1] > self.max_image_size[1]:
                    img = ImageOps.fit(img, self.max_image_size, Image.Resampling.LANCZOS)
                    self.stats['resized_images'] += 1
                
                # Para imagens críticas, mantém JPG otimizado
                if is_critical:
                    img.save(img_path, 'JPEG', quality=self.jpg_quality, optimize=True)
                else:
                    # Converte para WebP
                    webp_path = img_path.with_suffix('.webp')
                    img.save(webp_path, 'WEBP', quality=self.webp_quality, optimize=True)
                    
                    # Remove JPG original
                    img_path.unlink()
                    self.stats['webp_converted'] += 1
                
                new_size = (webp_path if not is_critical else img_path).stat().st_size
                self.stats['optimized_size'] += new_size
                
                reduction = ((original_size - new_size) / original_size) * 100
                if reduction > 10:  # Só mostra se reduziu mais de 10%
                    print(f"    ✅ {img_path.name}: {self._format_size(original_size)} → {self._format_size(new_size)} (-{reduction:.1f}%)")
                
                self.stats['images_processed'] += 1
                
        except Exception as e:
            print(f"    ❌ Erro em {img_path.name}: {e}")
            
    def _optimize_json_database(self):
        """Otimiza arquivos JSON do banco de dados"""
        print("\n📄 Otimizando database JSON...")
        
        total_original = 0
        total_compressed = 0
        files_processed = 0
        
        for json_file in self.database_path.rglob("*.json"):
            try:
                original_size = json_file.stat().st_size
                total_original += original_size
                
                # Lê, minifica e reescreve JSON
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                with open(json_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, separators=(',', ':'), ensure_ascii=False)
                
                new_size = json_file.stat().st_size
                total_compressed += new_size
                files_processed += 1
                
                reduction = ((original_size - new_size) / original_size) * 100
                if reduction > 5:  # Só mostra se reduziu mais de 5%
                    print(f"  ✅ {json_file.name}: {self._format_size(original_size)} → {self._format_size(new_size)} (-{reduction:.1f}%)")
                    
            except Exception as e:
                print(f"  ❌ Erro em {json_file.name}: {e}")
        
        print(f"  📊 {files_processed} arquivos JSON processados")
        total_reduction = ((total_original - total_compressed) / total_original) * 100
        print(f"  🗜️  Redução total: {self._format_size(total_original)} → {self._format_size(total_compressed)} (-{total_reduction:.1f}%)")
        
    def _prepare_remote_assets(self):
        """Prepara configuração para assets remotos"""
        print("\n☁️  Preparando configuração para assets remotos...")
        
        # Cria configuração de assets remotos
        remote_config = {
            "version": "1.0",
            "base_url": "https://assets.receituagro.com/images/",
            "fallback_url": "https://backup.receituagro.com/images/",
            "cache_duration_hours": 24,
            "critical_local_assets": [
                "a.jpg",
                "Nao classificado.jpg"
            ],
            "assets": []
        }
        
        # Lista todas as imagens para migração remota
        for img_file in self.images_path.glob("*"):
            if img_file.is_file() and img_file.name not in remote_config["critical_local_assets"]:
                remote_config["assets"].append({
                    "local_name": img_file.name,
                    "remote_path": img_file.name,
                    "size": img_file.stat().st_size,
                    "format": img_file.suffix[1:].lower()
                })
        
        # Salva configuração
        config_path = self.assets_path / "remote_assets_config.json"
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(remote_config, f, indent=2, ensure_ascii=False)
            
        print(f"  ✅ Configuração salva em: {config_path}")
        print(f"  📤 {len(remote_config['assets'])} assets marcados para migração remota")
        
    def _generate_report(self):
        """Gera relatório final da otimização"""
        print("\n📋 RELATÓRIO DE OTIMIZAÇÃO")
        print("=" * 50)
        
        # Calcula tamanho final
        final_size = 0
        for file_path in self.assets_path.rglob("*"):
            if file_path.is_file():
                final_size += file_path.stat().st_size
        
        self.stats['optimized_size'] = final_size
        self.stats['compression_ratio'] = ((self.stats['original_size'] - final_size) / self.stats['original_size']) * 100
        
        print(f"📊 ESTATÍSTICAS:")
        print(f"   Tamanho original: {self._format_size(self.stats['original_size'])}")
        print(f"   Tamanho otimizado: {self._format_size(final_size)}")
        print(f"   Redução total: {self.stats['compression_ratio']:.1f}%")
        print(f"   Economia: {self._format_size(self.stats['original_size'] - final_size)}")
        print()
        print(f"🖼️  IMAGENS:")
        print(f"   Processadas: {self.stats['images_processed']}")
        print(f"   Convertidas WebP: {self.stats['webp_converted']}")
        print(f"   Redimensionadas: {self.stats['resized_images']}")
        print()
        
        # Verifica se atingiu o objetivo
        target_size = 20 * 1024 * 1024  # 20MB
        if final_size <= target_size:
            print("🎯 OBJETIVO ATINGIDO! Assets <= 20MB")
        else:
            remaining = final_size - target_size
            print(f"⚠️  Ainda precisa reduzir {self._format_size(remaining)} para atingir 20MB")
            print("   💡 Sugestões:")
            print("   - Migrar mais imagens para assets remotos")
            print("   - Reduzir qualidade WebP para 75%")
            print("   - Implementar lazy loading do database JSON")
        
        print()
        print("✅ Otimização concluída!")
        
        # Salva relatório
        report_path = self.app_path / "optimization_report.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'stats': self.stats,
                'final_size_mb': round(final_size / (1024 * 1024), 2),
                'target_achieved': final_size <= target_size
            }, f, indent=2)
            
        print(f"📄 Relatório salvo em: {report_path}")
        
    def _format_size(self, size_bytes):
        """Formata tamanho em bytes para formato legível"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f}{unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f}TB"

def main():
    if len(sys.argv) != 2:
        print("Uso: python optimize_assets.py /path/to/app-receituagro")
        sys.exit(1)
    
    app_path = sys.argv[1]
    if not os.path.exists(app_path):
        print(f"❌ Diretório não encontrado: {app_path}")
        sys.exit(1)
    
    try:
        optimizer = AssetOptimizer(app_path)
        optimizer.run_optimization()
    except KeyboardInterrupt:
        print("\n⚠️  Otimização cancelada pelo usuário")
    except Exception as e:
        print(f"\n❌ Erro durante otimização: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()