create extension if not exists pgcrypto;

create table public.flows (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    title text not null,
    description text,
    notes text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table public.flow_exercises (
    id uuid primary key default gen_random_uuid(),
    flow_id uuid not null references public.flows (id) on delete cascade,
    canonical_exercise_key text,
    order_index integer not null,
    original_name text not null,
    display_name text not null,
    exercise_type text not null check (exercise_type in ('warmup', 'workout', 'stretch')),
    notes text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    constraint flow_exercises_flow_id_order_index_key unique (flow_id, order_index)
);

create table public.flow_exercise_sets (
    id uuid primary key default gen_random_uuid(),
    flow_exercise_id uuid not null references public.flow_exercises (id) on delete cascade,
    order_index integer not null,
    reps integer,
    duration_value numeric,
    duration_unit text,
    rest_seconds integer,
    weight_value numeric,
    weight_unit text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    constraint flow_exercise_sets_flow_exercise_id_order_index_key unique (flow_exercise_id, order_index)
);

create table public.import_drafts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users (id) on delete set null,
    raw_input text not null,
    draft_json jsonb not null,
    status text not null,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create index flows_user_id_idx on public.flows (user_id);
create index flow_exercises_flow_id_idx on public.flow_exercises (flow_id);
create index flow_exercises_canonical_exercise_key_idx on public.flow_exercises (canonical_exercise_key);
create index flow_exercise_sets_flow_exercise_id_idx on public.flow_exercise_sets (flow_exercise_id);
create index import_drafts_user_id_idx on public.import_drafts (user_id);
