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

create function todoapp_public.users_all_tasks(curr_user todoapp_public.user) returns setof todoapp_public.task as $$
  select task.*
  from todoapp_public.task as task
  where task.user_id = curr_user.id
  order by created_at desc
 $$ language sql stable;

comment on function todoapp_public.users_all_tasks(todoapp_public.user) is 'Get all users tasks.';


CREATE FUNCTION add(a int, b int) RETURNS int AS $$
  select a + b;
$$ LANGUAGE sql IMMUTABLE STRICT;
