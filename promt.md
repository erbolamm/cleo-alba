# Notas de Configuración OpenClaw

Este archivo contiene notas de referencia para la configuración de OpenClaw en dispositivos Android mediante Termux + proot-distro (Debian).

## Pasos de referencia

1. Instalar OpenClaw dentro de Debian vía proot-distro
2. Configurar el agente con personalidad e instrucciones
3. Conectar canal de Telegram
4. Configurar herramientas (Web Search, etc.)
5. Iniciar el gateway

## Comandos útiles

```bash
# Verificar estado
proot-distro login debian -- bash -c "openclaw status"

# Reiniciar gateway
proot-distro login debian -- bash -c "openclaw gateway restart"

# Ver logs
proot-distro login debian -- bash -c "tail -50 /root/openclaw.log"
```

## Notas
- Los tokens y claves se configuran en `Mis_configuraciones_locales/`
- Consultar `termux_scripts/OPENCLAW_TOOLS_MANUAL.md` para referencia completa