--
-- PostgreSQL database dump
--

\restrict 9xYFhYE7fpZwkY3QNfY5N9PmfZTLkbFoBbacbSEdg1EqMEKR5nM011NuGoC2aui

-- Dumped from database version 16.12 (Debian 16.12-1.pgdg13+1)
-- Dumped by pg_dump version 16.12 (Debian 16.12-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: audit_action; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.audit_action AS ENUM (
    'deal_lock',
    'deal_sold',
    'negotiation',
    'extension'
);


ALTER TYPE public.audit_action OWNER TO chimbo_admin;

--
-- Name: deal_status; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.deal_status AS ENUM (
    'pending',
    'locked',
    'sold',
    'expired'
);


ALTER TYPE public.deal_status OWNER TO chimbo_admin;

--
-- Name: negotiation_status; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.negotiation_status AS ENUM (
    'pending',
    'countered',
    'accepted',
    'rejected'
);


ALTER TYPE public.negotiation_status OWNER TO chimbo_admin;

--
-- Name: product_status; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.product_status AS ENUM (
    'active',
    'paused',
    'archived'
);


ALTER TYPE public.product_status OWNER TO chimbo_admin;

--
-- Name: subscription_plan; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.subscription_plan AS ENUM (
    'basic',
    'standard',
    'premium'
);


ALTER TYPE public.subscription_plan OWNER TO chimbo_admin;

--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.subscription_status AS ENUM (
    'active',
    'expired'
);


ALTER TYPE public.subscription_status OWNER TO chimbo_admin;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: chimbo_admin
--

CREATE TYPE public.user_role AS ENUM (
    'agent',
    'vendor',
    'admin'
);


ALTER TYPE public.user_role OWNER TO chimbo_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_performance; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.agent_performance (
    agent_id uuid NOT NULL,
    deals_closed integer DEFAULT 0,
    deals_dropped integer DEFAULT 0,
    success_rate numeric(5,2) DEFAULT 0.0,
    avg_sell_time numeric(10,2) DEFAULT 0.0,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.agent_performance OWNER TO chimbo_admin;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.audit_logs (
    log_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    action_type public.audit_action NOT NULL,
    target_id uuid,
    details json,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO chimbo_admin;

--
-- Name: deals; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.deals (
    deal_id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    status public.deal_status DEFAULT 'pending'::public.deal_status,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expiry_at timestamp without time zone NOT NULL,
    quantity integer,
    price numeric(10,2),
    locked_at timestamp without time zone,
    extension_count integer DEFAULT 0,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT deals_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT deals_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.deals OWNER TO chimbo_admin;

--
-- Name: negotiations; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.negotiations (
    negotiation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    deal_id uuid NOT NULL,
    agent_offer numeric(10,2) NOT NULL,
    vendor_offer numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    product_id uuid,
    agent_id uuid,
    vendor_id uuid,
    proposed_price numeric(10,2),
    quantity integer,
    status public.negotiation_status DEFAULT 'pending'::public.negotiation_status,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT negotiations_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.negotiations OWNER TO chimbo_admin;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.notifications (
    notification_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    message text NOT NULL,
    read_status boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO chimbo_admin;

--
-- Name: products; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.products (
    product_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    stock_quantity integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status public.product_status DEFAULT 'active'::public.product_status,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO chimbo_admin;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.subscriptions (
    subscription_id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status public.subscription_status DEFAULT 'active'::public.subscription_status,
    user_id uuid,
    plan_type public.subscription_plan,
    auto_renew boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.subscriptions OWNER TO chimbo_admin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    role public.user_role NOT NULL,
    password_hash character varying(255) NOT NULL,
    subscription_status boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    subscription_plan public.subscription_plan,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO chimbo_admin;

--
-- Name: vendor_performance; Type: TABLE; Schema: public; Owner: chimbo_admin
--

CREATE TABLE public.vendor_performance (
    performance_id uuid DEFAULT gen_random_uuid() NOT NULL,
    vendor_id uuid NOT NULL,
    deals_completed integer DEFAULT 0,
    response_rate numeric(5,2) DEFAULT 0.0,
    rating numeric(2,1) DEFAULT 0.0,
    deals_accepted integer DEFAULT 0,
    deals_confirmed integer DEFAULT 0,
    avg_confirmation_time numeric(10,2) DEFAULT 0.0,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vendor_performance OWNER TO chimbo_admin;

--
-- Name: agent_performance agent_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.agent_performance
    ADD CONSTRAINT agent_performance_pkey PRIMARY KEY (agent_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (log_id);


--
-- Name: deals deals_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT deals_pkey PRIMARY KEY (deal_id);


--
-- Name: negotiations negotiations_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.negotiations
    ADD CONSTRAINT negotiations_pkey PRIMARY KEY (negotiation_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);


--
-- Name: deals unique_agent_product_locked; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT unique_agent_product_locked UNIQUE (agent_id, product_id, status);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vendor_performance vendor_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.vendor_performance
    ADD CONSTRAINT vendor_performance_pkey PRIMARY KEY (performance_id);


--
-- Name: idx_agent_perf_agent; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_agent_perf_agent ON public.agent_performance USING btree (agent_id);


--
-- Name: idx_deals_agent; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_agent ON public.deals USING btree (agent_id);


--
-- Name: idx_deals_agent_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_agent_status ON public.deals USING btree (agent_id, status);


--
-- Name: idx_deals_expiry; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_expiry ON public.deals USING btree (expiry_at);


--
-- Name: idx_deals_expiry_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_expiry_status ON public.deals USING btree (expiry_at, status);


--
-- Name: idx_deals_product; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_product ON public.deals USING btree (product_id);


--
-- Name: idx_deals_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_status ON public.deals USING btree (status);


--
-- Name: idx_deals_vendor; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_vendor ON public.deals USING btree (vendor_id);


--
-- Name: idx_deals_vendor_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_deals_vendor_status ON public.deals USING btree (vendor_id, status);


--
-- Name: idx_negotiations_agent_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_negotiations_agent_status ON public.negotiations USING btree (agent_id, status);


--
-- Name: idx_negotiations_product; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_negotiations_product ON public.negotiations USING btree (product_id);


--
-- Name: idx_negotiations_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_negotiations_status ON public.negotiations USING btree (status);


--
-- Name: idx_negotiations_vendor_status; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_negotiations_vendor_status ON public.negotiations USING btree (vendor_id, status);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);


--
-- Name: idx_subscriptions_user; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_subscriptions_user ON public.subscriptions USING btree (user_id);


--
-- Name: idx_vendor_perf_vendor; Type: INDEX; Schema: public; Owner: chimbo_admin
--

CREATE INDEX idx_vendor_perf_vendor ON public.vendor_performance USING btree (vendor_id);


--
-- Name: deals fk_agent; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT fk_agent FOREIGN KEY (agent_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: agent_performance fk_agent_perf; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.agent_performance
    ADD CONSTRAINT fk_agent_perf FOREIGN KEY (agent_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: subscriptions fk_agent_sub; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT fk_agent_sub FOREIGN KEY (agent_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: negotiations fk_deal; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.negotiations
    ADD CONSTRAINT fk_deal FOREIGN KEY (deal_id) REFERENCES public.deals(deal_id) ON DELETE CASCADE;


--
-- Name: deals fk_product; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: audit_logs fk_user_log; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT fk_user_log FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: notifications fk_user_notif; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_user_notif FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: deals fk_vendor; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT fk_vendor FOREIGN KEY (vendor_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: products fk_vendor; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_vendor FOREIGN KEY (vendor_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: vendor_performance fk_vendor_perf; Type: FK CONSTRAINT; Schema: public; Owner: chimbo_admin
--

ALTER TABLE ONLY public.vendor_performance
    ADD CONSTRAINT fk_vendor_perf FOREIGN KEY (vendor_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 9xYFhYE7fpZwkY3QNfY5N9PmfZTLkbFoBbacbSEdg1EqMEKR5nM011NuGoC2aui

