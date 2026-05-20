// app.js - Inicialização do cliente Supabase
const SUPABASE_URL = 'https://ctobdkstnrhepixyujms.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0b2Jka3N0bnJoZXBpeHl1am1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MTAyOTAsImV4cCI6MjA5Mjk4NjI5MH0.mDuYyQI4rV4KsxN9SsfJj9zmiTx-KZlblcLq22KfIWg';
//const IMGBB_API_KEY = 'd3ec802e2dfc1896a26e44b80d489f17';

// Cria o cliente e guarda no objeto window para uso global
window.supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
