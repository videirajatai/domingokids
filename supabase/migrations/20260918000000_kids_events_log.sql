-- Domingo Kids - Fase 1: estrutura de log de eventos
-- Aplicar no Supabase (SQL Editor) do projeto asriklhdbzxubdcuauoz.
-- Cria: tabela kids_events_log, helper kids_is_admin(), RLS de leitura
-- (somente admin) e RPC kids_log_event() para o cliente registrar eventos.

create table if not exists public.kids_events_log (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  user_id uuid,
  actor_username text,
  actor_role text,
  event_type text not null,
  event_category text not null default 'system',
  severity text not null default 'info',
  description text,
  entity_type text,
  entity_id text,
  child_id uuid,
  child_name text,
  room text,
  session_id uuid,
  source text not null default 'client',
  page text,
  user_agent text,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_kids_events_created on public.kids_events_log (created_at desc);
create index if not exists idx_kids_events_cat on public.kids_events_log (event_category, created_at desc);
create index if not exists idx_kids_events_user on public.kids_events_log (user_id, created_at desc);
create index if not exists idx_kids_events_child on public.kids_events_log (child_id, created_at desc);

-- Helper para checar admin sem recursao de RLS em kids_profiles.
create or replace function public.kids_is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.kids_profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

revoke all on function public.kids_is_admin() from public;
grant execute on function public.kids_is_admin() to authenticated;

-- Leitura somente para administradores. Nao ha policy de insert:
-- o cliente grava exclusivamente pela RPC kids_log_event (security definer).
alter table public.kids_events_log enable row level security;

drop policy if exists "admins leem eventos" on public.kids_events_log;
create policy "admins leem eventos" on public.kids_events_log
  for select
  to authenticated
  using (public.kids_is_admin());

-- RPC unica de registro. Funciona autenticado e anonimo (login falho).
-- O user_id/actor sao sempre derivados da sessao, nunca do cliente.
create or replace function public.kids_log_event(
  p_event_type text,
  p_event_category text default 'system',
  p_severity text default 'info',
  p_description text default null,
  p_entity_type text default null,
  p_entity_id text default null,
  p_child_id uuid default null,
  p_child_name text default null,
  p_room text default null,
  p_session_id uuid default null,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_meta jsonb := coalesce(p_metadata, '{}'::jsonb);
begin
  insert into public.kids_events_log(
    user_id, actor_username, actor_role,
    event_type, event_category, severity, description,
    entity_type, entity_id, child_id, child_name, room, session_id,
    source, page, user_agent, metadata
  )
  values (
    v_uid,
    (select username from public.kids_profiles where id = v_uid),
    (select role from public.kids_profiles where id = v_uid),
    p_event_type,
    coalesce(nullif(p_event_category, ''), 'system'),
    coalesce(nullif(p_severity, ''), 'info'),
    p_description,
    p_entity_type, p_entity_id, p_child_id, p_child_name, p_room, p_session_id,
    'client',
    v_meta->>'page',
    v_meta->>'user_agent',
    v_meta - 'page' - 'user_agent'
  );
end;
$$;

revoke all on function public.kids_log_event(
  text, text, text, text, text, text, uuid, text, text, uuid, jsonb
) from public;
grant execute on function public.kids_log_event(
  text, text, text, text, text, text, uuid, text, text, uuid, jsonb
) to anon, authenticated;
