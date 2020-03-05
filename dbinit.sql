drop database if exists todo;


create database todo;
\connect todo;
drop schema if exists todoapp_public cascade;
drop schema if exists todoapp_private cascade;
create schema todoapp_public;
create schema todoapp_private;

create table todoapp_public.user (
  id serial primary key,
  name text check (char_length(name) < 80),
  created_at timestamp default now()
);

CREATE ROLE auth_postgraphile LOGIN PASSWORD 'password';
CREATE ROLE auth_anonymous;
GRANT auth_anonymous TO auth_postgraphile;
CREATE ROLE auth_authenticated;
GRANT auth_authenticated TO auth_postgraphile;

comment on table todoapp_public.user is 'A user.';
comment on column todoapp_public.user.id is 'The primary unique identifier for the user.';
comment on column todoapp_public.user.name is 'The user’s name.';
comment on column todoapp_public.user.created_at is 'The time this user was created.';



create table todoapp_private.user_account (
  user_id integer primary key references todoapp_public.user(id) on delete cascade,
  email text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash text not null
);

comment on table todoapp_private.user_account is 'A user private data.';
comment on column todoapp_private.user_account.user_id is 'The id of the user associated with this account.';
comment on column todoapp_private.user_account.email is 'The email address of the user.';
comment on column todoapp_private.user_account.password_hash is 'An opaque hash of the users password.';

create type todoapp_public.task_status as enum (
  'todo',
  'done'
);

create table todoapp_public.task (
  id serial primary key,
  user_id integer not null references todoapp_public.user(id),
  description text not null check (char_length(description) < 200),
  status todoapp_public.task_status,
  created_at timestamp default now()
);

comment on table todoapp_public.task is 'A users task table';
comment on column todoapp_public.task.id is 'The id of task';
comment on column todoapp_public.task.user_id is 'The id of user who created this task';
comment on column todoapp_public.task.description is 'The task description';
comment on column todoapp_public.task.status is 'The task status';
comment on column todoapp_public.task.created_at is 'The time this task was created.';

alter default privileges revoke execute on functions from public;

alter table todoapp_public.task add column updated_at timestamp default now();

create function todoapp_public.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

create trigger task_updated_at before update
  on todoapp_public.task
  for each row
  execute procedure todoapp_public.set_updated_at();

create extension if not exists "pgcrypto";

create function todoapp_public.register_user(
  name text,
  email text, 
  password text,
) returns todoapp_public.user as $$ 
  declare
    user todoapp_public.user;
  begin
    insert into todoapp_public.user (name) values
      (name)  
      returning * into user;

    insert into todoapp_private.user_account (user_id, email, password_hash) values
      (user.id, email, crypt(password, gen_salt('bf')));

    return user;
  end;
$$ language plpgsql strict security definer;

comment on function todoapp_public.register_user(text, text, text) is 'Registers a single user and creates an account in todo APP';