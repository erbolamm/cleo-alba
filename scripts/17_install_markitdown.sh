#!/bin/bash
# ============================================
# Instalación de MarkItDown en Debian (proot)
# ============================================

set -e

echo "=== ACTUALIZANDO SISTEMA Y DEPENDENCIAS ==="
apt update
apt install -y \
    python3-pip \
    python3-venv \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
    libjpeg-dev \
    tesseract-ocr \
    libtesseract-dev \
    poppler-utils \
    ffmpeg \
    libmagic-dev \
    git

echo "=== INSTALANDO MARKITDOWN ==="
# Instalamos globalmente o en el entorno del sistema ya que estamos en un contenedor proot controlado
# MarkItDown requiere python >= 3.10, verificado que tenemos 3.13
pip3 install --break-system-packages markitdown mcp

echo "=== VERIFICANDO INSTALACIÓN ==="
markitdown --version || echo "⚠️ markitdown no se encontró en el PATH directamente"

echo "✅ Instalación completada"
