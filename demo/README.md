# 🦀 Demo ClawMobil

## Instalación rápida en cualquier teléfono Android

### Lo que necesitas:
- Un ordenador con **macOS** o **Linux**
- Un cable USB
- Un teléfono Android con [Depuración USB](https://developer.android.com/studio/debug/dev-options) activada

### Pasos:

1. **Conecta** el teléfono Android por USB al ordenador
2. **Acepta** el popup "¿Permitir depuración USB?" en el teléfono
3. **Ejecuta** el instalador:

```bash
./instalar_claw.sh
```

4. ¡Listo! La App **ClawMobil Chat** se abre automáticamente 🦀

### ¿Qué hace el script?

- Detecta automáticamente el teléfono conectado
- Instala la app ClawMobil Chat 
- Abre la app al terminar

### Servidor de IA

Para que Claw responda, necesitas un servidor Ollama corriendo. Puede ser:

- **En el mismo teléfono** (con Termux + Ollama)
- **En otro dispositivo** de la red local

La app se conecta a `localhost:11434` por defecto. Si el servidor está en otro dispositivo, cambia la URL en ⚙️ Ajustes.

### Compilar la APK tú mismo

```bash
cd ../Mis_configuraciones_locales/dispositivos/yestel_server/chat_app
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ../../../demo/ClawMobil-Chat.apk
```

---

**Creado por Francisco** | [apliarte.com](https://apliarte.com) | [GitHub](https://github.com/erbolamm/ClawMobil)
