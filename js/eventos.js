// js/eventos.js
// Registro central de eventos de usuario no Supabase (tabela kids_events_log).
// Depende do cliente global `supabaseClient` (criado em cada pagina).
// Nao lanca excecao: falhas de log nunca devem quebrar o fluxo do usuario.
(function () {
    'use strict';

    var TIMEOUT_MS = 2500;

    function comTimeout(promise, ms) {
        return new Promise(function (resolve) {
            var done = false;
            var timer = setTimeout(function () {
                if (!done) { done = true; resolve(); }
            }, ms);
            Promise.resolve(promise).then(function () {
                if (!done) { done = true; clearTimeout(timer); resolve(); }
            }, function () {
                if (!done) { done = true; clearTimeout(timer); resolve(); }
            });
        });
    }

    // registrarEvento('login_success', { category, severity, description, ... })
    // opts: category, severity, description, entityType, entityId, childId,
    //       childName, room, sessionId, metadata
    window.registrarEvento = function (eventType, opts) {
        try {
            if (!eventType) return Promise.resolve();
            if (typeof supabaseClient === 'undefined' || !supabaseClient) return Promise.resolve();

            var o = opts || {};
            var meta = Object.assign({
                page: (window.location && window.location.pathname) || null,
                user_agent: navigator.userAgent || null
            }, o.metadata || {});

            var args = {
                p_event_type: String(eventType),
                p_event_category: o.category || 'system',
                p_severity: o.severity || 'info',
                p_description: o.description || null,
                p_entity_type: o.entityType || null,
                p_entity_id: o.entityId != null ? String(o.entityId) : null,
                p_child_id: o.childId || null,
                p_child_name: o.childName || null,
                p_room: o.room || null,
                p_session_id: o.sessionId || null,
                p_metadata: meta
            };

            return comTimeout(supabaseClient.rpc('kids_log_event', args), TIMEOUT_MS);
        } catch (e) {
            return Promise.resolve();
        }
    };
})();
