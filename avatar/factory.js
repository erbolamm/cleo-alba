/** Bot Factory Logic **/

let currentPersona = 'assistant';

// Clock updates
setInterval(() => {
    const now = new Date();
    document.getElementById('clock').innerText = now.toLocaleTimeString();
}, 1000);

function selectPersona(persona) {
    currentPersona = persona;
    // Update UI
    document.querySelectorAll('.persona-item').forEach(item => {
        item.classList.remove('active');
    });
    event.currentTarget.classList.add('active');

    addMessage('bot', `Has seleccionado la personalidad: **${persona}**. Pulsa "Activar Bot" para aplicarlo.`);
}

async function launchBot() {
    addMessage('bot', '🚀 Aplicando configuración al bot...');

    try {
        const response = await fetch('/api/factory/launch', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ persona: currentPersona })
        });
        const result = await response.json();

        if (result.status === 'ok') {
            addMessage('bot', '✅ ¡Bot activado con éxito! Ya puedes hablarle.');
        } else {
            addMessage('bot', '❌ Error al activar: ' + (result.error || 'Desconocido'));
        }
    } catch (e) {
        addMessage('bot', '❌ Error de conexión con el cerebro.');
    }
}

async function askWizard() {
    const input = document.getElementById('wizardInput');
    const text = input.value.trim();
    if (!text) return;

    input.value = '';
    addMessage('user', text);

    addMessage('bot', '✨ Analizando requerimientos y creando prompt maestro...');

    try {
        const response = await fetch('/api/factory/wizard', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ description: text })
        });
        const result = await response.json();

        if (result.prompt) {
            addMessage('bot', '**Alma creada:**\n' + result.prompt);
            addMessage('bot', '¿Quieres aplicar esta configuración ahora? <button class="btn-primary" onclick="applyCustomPrompt()">Sí, aplicar</button>', true);
            window.lastCustomPrompt = result.prompt;
        }
    } catch (e) {
        addMessage('bot', '❌ Error al contactar con el arquitecto.');
    }
}

async function applyCustomPrompt() {
    if (!window.lastCustomPrompt) return;

    addMessage('bot', '🔧 Inyectando nueva identidad...');
    try {
        const response = await fetch('/api/factory/launch', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ custom_prompt: window.lastCustomPrompt })
        });
        addMessage('bot', '✅ Identidad inyectada. ¡Bot reiniciado!');
    } catch (e) {
        addMessage('bot', '❌ Error al inyectar identidad.');
    }
}

function addMessage(type, text, isHTML = false) {
    const chat = document.getElementById('wizardChat');
    const bubble = document.createElement('div');
    bubble.className = `chat-bubble ${type}-bubble`;

    if (isHTML) {
        bubble.innerHTML = text;
    } else {
        bubble.innerText = text;
    }

    chat.appendChild(bubble);
    chat.scrollTop = chat.scrollHeight;
}
