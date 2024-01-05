--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.25
-- Dumped by pg_dump version 9.5.25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contest_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contest_relations (
    id integer NOT NULL,
    user_id integer,
    contest_id integer,
    started_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    finish_at timestamp without time zone,
    score integer DEFAULT 0 NOT NULL,
    time_taken double precision DEFAULT 0.0 NOT NULL,
    school_id integer,
    status integer DEFAULT 0,
    extra_time integer DEFAULT 0,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    country_code character varying(2),
    school_year integer,
    supervisor_id integer,
    checked_in boolean DEFAULT false
);


--
-- Name: contest_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contest_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contest_relations_id_seq OWNED BY public.contest_relations.id;


--
-- Name: contest_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contest_scores (
    id integer NOT NULL,
    contest_relation_id integer NOT NULL,
    problem_id integer NOT NULL,
    score integer,
    attempts integer,
    attempt integer,
    submission_id integer,
    updated_at timestamp without time zone
);


--
-- Name: contest_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contest_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contest_scores_id_seq OWNED BY public.contest_scores.id;


--
-- Name: contest_supervisors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contest_supervisors (
    id integer NOT NULL,
    contest_id integer,
    user_id integer,
    site_type character varying,
    site_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scheduled_start_time timestamp without time zone
);


--
-- Name: contest_supervisors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contest_supervisors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contest_supervisors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contest_supervisors_id_seq OWNED BY public.contest_supervisors.id;


--
-- Name: contests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contests (
    id integer NOT NULL,
    name character varying,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration numeric,
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    problem_set_id integer,
    finalized_at timestamp without time zone,
    startcode character varying,
    observation integer DEFAULT 1,
    registration integer DEFAULT 0,
    affiliation integer DEFAULT 0,
    live_scoreboard boolean DEFAULT true,
    only_rank_official_contestants boolean DEFAULT false
);


--
-- Name: contests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contests_id_seq OWNED BY public.contests.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id integer NOT NULL,
    name character varying,
    entity_id integer,
    entity_type character varying
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entities_id_seq OWNED BY public.entities.id;


--
-- Name: evaluators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evaluators (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    source text DEFAULT ''::text NOT NULL,
    owner_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: evaluators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evaluators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evaluators_id_seq OWNED BY public.evaluators.id;


--
-- Name: file_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_attachments (
    id integer NOT NULL,
    name character varying,
    file_attachment character varying,
    owner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_attachments_id_seq OWNED BY public.file_attachments.id;


--
-- Name: filelinks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.filelinks (
    id integer NOT NULL,
    root_id integer,
    file_attachment_id integer,
    created_at timestamp without time zone,
    filepath character varying,
    root_type character varying,
    visibility smallint DEFAULT 0
);


--
-- Name: filelinks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.filelinks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filelinks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.filelinks_id_seq OWNED BY public.filelinks.id;


--
-- Name: group_contests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_contests (
    id integer NOT NULL,
    group_id integer,
    contest_id integer
);


--
-- Name: group_contests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_contests_id_seq OWNED BY public.group_contests.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_memberships (
    id integer NOT NULL,
    group_id integer,
    member_id integer,
    created_at timestamp without time zone
);


--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_memberships_id_seq OWNED BY public.group_memberships.id;


--
-- Name: group_problem_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_problem_sets (
    id integer NOT NULL,
    group_id integer,
    problem_set_id integer,
    name character varying
);


--
-- Name: group_problem_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_problem_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_problem_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_problem_sets_id_seq OWNED BY public.group_problem_sets.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id integer,
    visibility integer DEFAULT 0 NOT NULL,
    membership integer DEFAULT 0 NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: item_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_histories (
    id integer NOT NULL,
    item_id integer,
    active boolean,
    action integer,
    holder_id integer,
    data character varying,
    acted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: item_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_histories_id_seq OWNED BY public.item_histories.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id integer NOT NULL,
    product_id integer,
    owner_id integer,
    organisation_id integer,
    sponsor_id integer,
    condition integer,
    status integer,
    holder_id integer,
    donator_id integer,
    scan_token integer
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: language_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.language_groups (
    id integer NOT NULL,
    identifier character varying,
    name character varying,
    current_language_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: language_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.language_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: language_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.language_groups_id_seq OWNED BY public.language_groups.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.languages (
    id integer NOT NULL,
    identifier character varying,
    compiler character varying,
    interpreted boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extension character varying,
    compiled boolean,
    name character varying,
    lexer character varying,
    group_id integer,
    source_filename character varying,
    exe_extension character varying,
    compiler_command character varying,
    interpreter character varying,
    interpreter_command character varying,
    processes integer DEFAULT 1
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id integer NOT NULL
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organisations_id_seq OWNED BY public.organisations.id;


--
-- Name: problem_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problem_series (
    id integer NOT NULL,
    name character varying,
    identifier character varying,
    importer_type character varying,
    index_yaml text
);


--
-- Name: problem_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problem_series_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problem_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problem_series_id_seq OWNED BY public.problem_series.id;


--
-- Name: problem_set_problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problem_set_problems (
    id integer NOT NULL,
    problem_set_id integer,
    problem_id integer,
    problem_set_order integer,
    weighting integer DEFAULT 100
);


--
-- Name: problem_set_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problem_set_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problem_set_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problem_set_problems_id_seq OWNED BY public.problem_set_problems.id;


--
-- Name: problem_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problem_sets (
    id integer NOT NULL,
    name character varying,
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    finalized_contests_count integer DEFAULT 0
);


--
-- Name: problem_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problem_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problem_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problem_sets_id_seq OWNED BY public.problem_sets.id;


--
-- Name: problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.problems (
    id integer NOT NULL,
    name character varying,
    statement text,
    input character varying,
    output character varying,
    memory_limit integer,
    time_limit numeric,
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    evaluator_id integer,
    rejudge_at timestamp without time zone,
    test_error_count integer DEFAULT 0,
    test_warning_count integer DEFAULT 0,
    test_status integer DEFAULT 0
);


--
-- Name: problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.problems_id_seq OWNED BY public.problems.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying,
    gtin bigint,
    description text,
    image character varying
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requests (
    id integer NOT NULL,
    requester_id integer,
    subject_id integer,
    subject_type character varying,
    verb character varying NOT NULL,
    target_id integer NOT NULL,
    target_type character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    requestee_id integer,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requests_id_seq OWNED BY public.requests.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_users (
    role_id integer,
    user_id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id integer NOT NULL,
    name character varying,
    country_code character varying(2),
    users_count integer,
    synonym_id integer
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    key character varying,
    value character varying
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.submissions (
    id integer NOT NULL,
    source text,
    score integer,
    user_id integer,
    problem_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    input character varying,
    output character varying,
    language_id integer,
    judge_log text,
    judged_at timestamp without time zone,
    job character varying,
    classification integer,
    test_errors character varying[],
    test_warnings character varying[],
    evaluation double precision,
    points numeric,
    maximum_points integer
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.submissions_id_seq OWNED BY public.submissions.id;


--
-- Name: test_case_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_case_relations (
    id integer NOT NULL,
    test_case_id integer,
    test_set_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: test_case_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_case_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_case_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_case_relations_id_seq OWNED BY public.test_case_relations.id;


--
-- Name: test_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_cases (
    id integer NOT NULL,
    input text,
    output text,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    problem_id integer,
    sample boolean DEFAULT false,
    problem_order integer
);


--
-- Name: test_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_cases_id_seq OWNED BY public.test_cases.id;


--
-- Name: test_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_sets (
    id integer NOT NULL,
    problem_id integer,
    points integer,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    prerequisite boolean DEFAULT false,
    problem_order integer
);


--
-- Name: test_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_sets_id_seq OWNED BY public.test_sets.id;


--
-- Name: user_problem_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_problem_relations (
    id integer NOT NULL,
    problem_id integer,
    user_id integer,
    submissions_count integer,
    ranked_score integer,
    ranked_submission_id integer,
    submission_id integer,
    last_viewed_at timestamp without time zone,
    first_viewed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_problem_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_problem_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_problem_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_problem_relations_id_seq OWNED BY public.user_problem_relations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    brownie_points integer DEFAULT 0,
    name character varying,
    username character varying NOT NULL,
    can_change_username boolean DEFAULT false NOT NULL,
    avatar character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    last_seen_at timestamp without time zone,
    school_id integer,
    country_code character varying(3),
    school_graduation date
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_relations ALTER COLUMN id SET DEFAULT nextval('public.contest_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_scores ALTER COLUMN id SET DEFAULT nextval('public.contest_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_supervisors ALTER COLUMN id SET DEFAULT nextval('public.contest_supervisors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contests ALTER COLUMN id SET DEFAULT nextval('public.contests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities ALTER COLUMN id SET DEFAULT nextval('public.entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluators ALTER COLUMN id SET DEFAULT nextval('public.evaluators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_attachments ALTER COLUMN id SET DEFAULT nextval('public.file_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filelinks ALTER COLUMN id SET DEFAULT nextval('public.filelinks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_contests ALTER COLUMN id SET DEFAULT nextval('public.group_contests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships ALTER COLUMN id SET DEFAULT nextval('public.group_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_problem_sets ALTER COLUMN id SET DEFAULT nextval('public.group_problem_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_histories ALTER COLUMN id SET DEFAULT nextval('public.item_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.language_groups ALTER COLUMN id SET DEFAULT nextval('public.language_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations ALTER COLUMN id SET DEFAULT nextval('public.organisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_series ALTER COLUMN id SET DEFAULT nextval('public.problem_series_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_set_problems ALTER COLUMN id SET DEFAULT nextval('public.problem_set_problems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_sets ALTER COLUMN id SET DEFAULT nextval('public.problem_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problems ALTER COLUMN id SET DEFAULT nextval('public.problems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests ALTER COLUMN id SET DEFAULT nextval('public.requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions ALTER COLUMN id SET DEFAULT nextval('public.submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_case_relations ALTER COLUMN id SET DEFAULT nextval('public.test_case_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_cases ALTER COLUMN id SET DEFAULT nextval('public.test_cases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_sets ALTER COLUMN id SET DEFAULT nextval('public.test_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_problem_relations ALTER COLUMN id SET DEFAULT nextval('public.user_problem_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: contest_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_relations
    ADD CONSTRAINT contest_relations_pkey PRIMARY KEY (id);


--
-- Name: contest_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_scores
    ADD CONSTRAINT contest_scores_pkey PRIMARY KEY (id);


--
-- Name: contest_supervisors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contest_supervisors
    ADD CONSTRAINT contest_supervisors_pkey PRIMARY KEY (id);


--
-- Name: contests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contests
    ADD CONSTRAINT contests_pkey PRIMARY KEY (id);


--
-- Name: entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: evaluators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluators
    ADD CONSTRAINT evaluators_pkey PRIMARY KEY (id);


--
-- Name: file_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_attachments
    ADD CONSTRAINT file_attachments_pkey PRIMARY KEY (id);


--
-- Name: filelinks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.filelinks
    ADD CONSTRAINT filelinks_pkey PRIMARY KEY (id);


--
-- Name: group_contests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_contests
    ADD CONSTRAINT group_contests_pkey PRIMARY KEY (id);


--
-- Name: group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: group_problem_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_problem_sets
    ADD CONSTRAINT group_problem_sets_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: item_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_histories
    ADD CONSTRAINT item_histories_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: language_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.language_groups
    ADD CONSTRAINT language_groups_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: problem_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_series
    ADD CONSTRAINT problem_series_pkey PRIMARY KEY (id);


--
-- Name: problem_set_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_set_problems
    ADD CONSTRAINT problem_set_problems_pkey PRIMARY KEY (id);


--
-- Name: problem_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problem_sets
    ADD CONSTRAINT problem_sets_pkey PRIMARY KEY (id);


--
-- Name: problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: test_case_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_case_relations
    ADD CONSTRAINT test_case_relations_pkey PRIMARY KEY (id);


--
-- Name: test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_cases
    ADD CONSTRAINT test_cases_pkey PRIMARY KEY (id);


--
-- Name: test_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_sets
    ADD CONSTRAINT test_sets_pkey PRIMARY KEY (id);


--
-- Name: user_problem_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_problem_relations
    ADD CONSTRAINT user_problem_relations_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_contest_relations_on_contest_id_and_score_and_time_taken; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contest_relations_on_contest_id_and_score_and_time_taken ON public.contest_relations USING btree (contest_id, score DESC, time_taken);


--
-- Name: index_contest_relations_on_contest_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contest_relations_on_contest_id_and_user_id ON public.contest_relations USING btree (contest_id, user_id);


--
-- Name: index_contest_relations_on_user_id_and_started_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contest_relations_on_user_id_and_started_at ON public.contest_relations USING btree (user_id, started_at);


--
-- Name: index_contest_scores_on_contest_relation_id_and_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contest_scores_on_contest_relation_id_and_problem_id ON public.contest_scores USING btree (contest_relation_id, problem_id);


--
-- Name: index_filelinks_on_file_attachment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filelinks_on_file_attachment_id ON public.filelinks USING btree (file_attachment_id);


--
-- Name: index_filelinks_on_root_id_and_filepath; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filelinks_on_root_id_and_filepath ON public.filelinks USING btree (root_id, filepath);


--
-- Name: index_group_contests_on_contest_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_contests_on_contest_id_and_group_id ON public.group_contests USING btree (contest_id, group_id);


--
-- Name: index_group_contests_on_group_id_and_contest_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_contests_on_group_id_and_contest_id ON public.group_contests USING btree (group_id, contest_id);


--
-- Name: index_group_problem_sets_on_group_id_and_problem_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_problem_sets_on_group_id_and_problem_set_id ON public.group_problem_sets USING btree (group_id, problem_set_id);


--
-- Name: index_group_problem_sets_on_problem_set_id_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_problem_sets_on_problem_set_id_and_group_id ON public.group_problem_sets USING btree (problem_set_id, group_id);


--
-- Name: index_language_groups_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_language_groups_on_identifier ON public.language_groups USING btree (identifier);


--
-- Name: index_languages_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_languages_on_identifier ON public.languages USING btree (identifier);


--
-- Name: index_problem_set_problems_on_problem_id_and_problem_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_problem_set_problems_on_problem_id_and_problem_set_id ON public.problem_set_problems USING btree (problem_id, problem_set_id);


--
-- Name: index_problem_set_problems_on_problem_set_id_and_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_problem_set_problems_on_problem_set_id_and_problem_id ON public.problem_set_problems USING btree (problem_set_id, problem_id);


--
-- Name: index_sessions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_created_at ON public.sessions USING btree (created_at);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_settings_on_key ON public.settings USING btree (key);


--
-- Name: index_submissions_on_problem_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_problem_id_and_created_at ON public.submissions USING btree (problem_id, created_at);


--
-- Name: index_submissions_on_user_id_and_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_user_id_and_problem_id ON public.submissions USING btree (user_id, problem_id);


--
-- Name: index_test_case_relations_on_test_case_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_case_relations_on_test_case_id ON public.test_case_relations USING btree (test_case_id);


--
-- Name: index_test_case_relations_on_test_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_case_relations_on_test_set_id ON public.test_case_relations USING btree (test_set_id);


--
-- Name: index_test_cases_on_problem_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_test_cases_on_problem_id_and_name ON public.test_cases USING btree (problem_id, name);


--
-- Name: index_test_sets_on_problem_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_test_sets_on_problem_id_and_name ON public.test_sets USING btree (problem_id, name);


--
-- Name: index_user_problem_relations_on_problem_id_and_ranked_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_problem_relations_on_problem_id_and_ranked_score ON public.user_problem_relations USING btree (problem_id, ranked_score);


--
-- Name: index_user_problem_relations_on_user_id_and_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_problem_relations_on_user_id_and_problem_id ON public.user_problem_relations USING btree (user_id, problem_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20110819224757');

INSERT INTO schema_migrations (version) VALUES ('20110820005833');

INSERT INTO schema_migrations (version) VALUES ('20110820010205');

INSERT INTO schema_migrations (version) VALUES ('20110820013719');

INSERT INTO schema_migrations (version) VALUES ('20110904033519');

INSERT INTO schema_migrations (version) VALUES ('20110904033742');

INSERT INTO schema_migrations (version) VALUES ('20110904045150');

INSERT INTO schema_migrations (version) VALUES ('20110924030742');

INSERT INTO schema_migrations (version) VALUES ('20110924035337');

INSERT INTO schema_migrations (version) VALUES ('20110925021620');

INSERT INTO schema_migrations (version) VALUES ('20111002021523');

INSERT INTO schema_migrations (version) VALUES ('20111022023246');

INSERT INTO schema_migrations (version) VALUES ('20111206102437');

INSERT INTO schema_migrations (version) VALUES ('20120109132817');

INSERT INTO schema_migrations (version) VALUES ('20120111090946');

INSERT INTO schema_migrations (version) VALUES ('20120115015112');

INSERT INTO schema_migrations (version) VALUES ('20120115020222');

INSERT INTO schema_migrations (version) VALUES ('20120115044124');

INSERT INTO schema_migrations (version) VALUES ('20120115044140');

INSERT INTO schema_migrations (version) VALUES ('20120115050204');

INSERT INTO schema_migrations (version) VALUES ('20120117133515');

INSERT INTO schema_migrations (version) VALUES ('20120119025544');

INSERT INTO schema_migrations (version) VALUES ('20120119081526');

INSERT INTO schema_migrations (version) VALUES ('20120122061329');

INSERT INTO schema_migrations (version) VALUES ('20120127063021');

INSERT INTO schema_migrations (version) VALUES ('20120128000525');

INSERT INTO schema_migrations (version) VALUES ('20120128235138');

INSERT INTO schema_migrations (version) VALUES ('20120131100212');

INSERT INTO schema_migrations (version) VALUES ('20120201080849');

INSERT INTO schema_migrations (version) VALUES ('20120201113029');

INSERT INTO schema_migrations (version) VALUES ('20120202100212');

INSERT INTO schema_migrations (version) VALUES ('20120208061444');

INSERT INTO schema_migrations (version) VALUES ('20120210235859');

INSERT INTO schema_migrations (version) VALUES ('20120610045635');

INSERT INTO schema_migrations (version) VALUES ('20120805020042');

INSERT INTO schema_migrations (version) VALUES ('20120805021508');

INSERT INTO schema_migrations (version) VALUES ('20120805061859');

INSERT INTO schema_migrations (version) VALUES ('20120805105347');

INSERT INTO schema_migrations (version) VALUES ('20120806025011');

INSERT INTO schema_migrations (version) VALUES ('20120806212034');

INSERT INTO schema_migrations (version) VALUES ('20120807033035');

INSERT INTO schema_migrations (version) VALUES ('20120807042326');

INSERT INTO schema_migrations (version) VALUES ('20120810041325');

INSERT INTO schema_migrations (version) VALUES ('20130116092216');

INSERT INTO schema_migrations (version) VALUES ('20130926021023');

INSERT INTO schema_migrations (version) VALUES ('20130926065258');

INSERT INTO schema_migrations (version) VALUES ('20130926080926');

INSERT INTO schema_migrations (version) VALUES ('20130926105411');

INSERT INTO schema_migrations (version) VALUES ('20130928133936');

INSERT INTO schema_migrations (version) VALUES ('20131001082750');

INSERT INTO schema_migrations (version) VALUES ('20131001083843');

INSERT INTO schema_migrations (version) VALUES ('20131002083519');

INSERT INTO schema_migrations (version) VALUES ('20131007002316');

INSERT INTO schema_migrations (version) VALUES ('20131007025034');

INSERT INTO schema_migrations (version) VALUES ('20131013045616');

INSERT INTO schema_migrations (version) VALUES ('20131013050536');

INSERT INTO schema_migrations (version) VALUES ('20131112032835');

INSERT INTO schema_migrations (version) VALUES ('20131117055333');

INSERT INTO schema_migrations (version) VALUES ('20131123054446');

INSERT INTO schema_migrations (version) VALUES ('20131130104622');

INSERT INTO schema_migrations (version) VALUES ('20131201203759');

INSERT INTO schema_migrations (version) VALUES ('20131205080753');

INSERT INTO schema_migrations (version) VALUES ('20131205201359');

INSERT INTO schema_migrations (version) VALUES ('20131206074948');

INSERT INTO schema_migrations (version) VALUES ('20131207080120');

INSERT INTO schema_migrations (version) VALUES ('20131207091535');

INSERT INTO schema_migrations (version) VALUES ('20131208014408');

INSERT INTO schema_migrations (version) VALUES ('20131208015044');

INSERT INTO schema_migrations (version) VALUES ('20131208131723');

INSERT INTO schema_migrations (version) VALUES ('20131209063832');

INSERT INTO schema_migrations (version) VALUES ('20131217112526');

INSERT INTO schema_migrations (version) VALUES ('20131219035927');

INSERT INTO schema_migrations (version) VALUES ('20131219083253');

INSERT INTO schema_migrations (version) VALUES ('20131220034551');

INSERT INTO schema_migrations (version) VALUES ('20131221014009');

INSERT INTO schema_migrations (version) VALUES ('20131221101354');

INSERT INTO schema_migrations (version) VALUES ('20131222021036');

INSERT INTO schema_migrations (version) VALUES ('20131222110552');

INSERT INTO schema_migrations (version) VALUES ('20131224231543');

INSERT INTO schema_migrations (version) VALUES ('20131226232008');

INSERT INTO schema_migrations (version) VALUES ('20131226234044');

INSERT INTO schema_migrations (version) VALUES ('20140206025958');

INSERT INTO schema_migrations (version) VALUES ('20140215031939');

INSERT INTO schema_migrations (version) VALUES ('20140215032346');

INSERT INTO schema_migrations (version) VALUES ('20140215033457');

INSERT INTO schema_migrations (version) VALUES ('20140216002137');

INSERT INTO schema_migrations (version) VALUES ('20140218212023');

INSERT INTO schema_migrations (version) VALUES ('20141224080737');

INSERT INTO schema_migrations (version) VALUES ('20141224134542');

INSERT INTO schema_migrations (version) VALUES ('20150107090445');

INSERT INTO schema_migrations (version) VALUES ('20150107090450');

INSERT INTO schema_migrations (version) VALUES ('20150109101859');

INSERT INTO schema_migrations (version) VALUES ('20150116004052');

INSERT INTO schema_migrations (version) VALUES ('20150116010255');

INSERT INTO schema_migrations (version) VALUES ('20150117065146');

INSERT INTO schema_migrations (version) VALUES ('20150117073551');

INSERT INTO schema_migrations (version) VALUES ('20150118010607');

INSERT INTO schema_migrations (version) VALUES ('20150118104425');

INSERT INTO schema_migrations (version) VALUES ('20150121113050');

INSERT INTO schema_migrations (version) VALUES ('20150124223718');

INSERT INTO schema_migrations (version) VALUES ('20150204112552');

INSERT INTO schema_migrations (version) VALUES ('20150206053259');

INSERT INTO schema_migrations (version) VALUES ('20160123214252');

INSERT INTO schema_migrations (version) VALUES ('20160124011422');

INSERT INTO schema_migrations (version) VALUES ('20160124011836');

INSERT INTO schema_migrations (version) VALUES ('20160130235209');

INSERT INTO schema_migrations (version) VALUES ('20160131000430');

INSERT INTO schema_migrations (version) VALUES ('20200418113600');

INSERT INTO schema_migrations (version) VALUES ('20200418113601');

