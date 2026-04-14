# Supabase Project

This directory contains the active Supabase project assets for LiftFlow.

- `config.toml`: local Supabase CLI project configuration
- `migrations/`: SQL schema migrations intended for the Supabase CLI

The initial schema migration defines the current LiftFlow tables directly from
the audited data model and commits the project to UUID primary keys.
