PGDMP         ,                y           abpes    13.1    13.3 K    .           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            /           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            0           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            1           1262    25152    abpes    DATABASE     P   CREATE DATABASE abpes WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C';
    DROP DATABASE abpes;
                postgres    false            �            1255    25153    client_counter()    FUNCTION     �   CREATE FUNCTION public.client_counter() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify('current_client_counter',
					NEW.current_client_counter::text);
  RETURN NEW;
END;
$$;
 '   DROP FUNCTION public.client_counter();
       public          postgres    false            �            1255    25154    client_counter_function()    FUNCTION     c   CREATE FUNCTION public.client_counter_function() RETURNS void
    LANGUAGE sql
    AS $$
begin
$$;
 0   DROP FUNCTION public.client_counter_function();
       public          postgres    false            �            1259    25518    blockstatisticobject    TABLE     v  CREATE TABLE public.blockstatisticobject (
    block_id text,
    received_time timestamp with time zone,
    client_id text,
    number_of_transactions integer,
    number_of_actions integer,
    cumulative_count integer,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    block_num integer,
    tx_id_list text,
    uid integer NOT NULL
);
 (   DROP TABLE public.blockstatisticobject;
       public         heap    postgres    false            �            1259    25546    blockstatisticobject_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.blockstatisticobject_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.blockstatisticobject_uid_seq;
       public          postgres    false    221            2           0    0    blockstatisticobject_uid_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.blockstatisticobject_uid_seq OWNED BY public.blockstatisticobject.uid;
          public          postgres    false    222            �            1259    25155    clientcoordination    TABLE     �   CREATE TABLE public.clientcoordination (
    current_client_counter integer DEFAULT 1 NOT NULL,
    run_id text NOT NULL,
    date timestamp with time zone,
    uid integer NOT NULL
);
 &   DROP TABLE public.clientcoordination;
       public         heap    postgres    false            �            1259    25162    clientcoordination_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.clientcoordination_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.clientcoordination_uid_seq;
       public          postgres    false    200            3           0    0    clientcoordination_uid_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.clientcoordination_uid_seq OWNED BY public.clientcoordination.uid;
          public          postgres    false    201            �            1259    25164    clientexecutorstatistics    TABLE     H  CREATE TABLE public.clientexecutorstatistics (
    complete_start_time_format timestamp with time zone,
    complete_end_time_format timestamp with time zone,
    total_runtime double precision,
    client_id text,
    read_requests integer,
    write_requests integer,
    total_number_of_requests integer,
    exclude_failed_read_requests boolean,
    exclude_failed_write_requests boolean,
    failed_total integer,
    successful_total integer,
    rptu double precision,
    wptu double precision,
    fptu double precision,
    sptu double precision,
    tptu double precision,
    cpu_usage double precision,
    average_cpu_usage_per_core double precision,
    cumulative_count integer,
    conversion_type double precision,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 ,   DROP TABLE public.clientexecutorstatistics;
       public         heap    postgres    false            �            1259    25322     clientexecutorstatistics_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.clientexecutorstatistics_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.clientexecutorstatistics_uid_seq;
       public          postgres    false    202            4           0    0     clientexecutorstatistics_uid_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.clientexecutorstatistics_uid_seq OWNED BY public.clientexecutorstatistics.uid;
          public          postgres    false    215            �            1259    25172    customstatisticobject    TABLE     �   CREATE TABLE public.customstatisticobject (
    shared_id text,
    id text,
    basic_system text,
    statistic_type text,
    value text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 )   DROP TABLE public.customstatisticobject;
       public         heap    postgres    false            �            1259    25333    customstatisticobject_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.customstatisticobject_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.customstatisticobject_uid_seq;
       public          postgres    false    203            5           0    0    customstatisticobject_uid_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.customstatisticobject_uid_seq OWNED BY public.customstatisticobject.uid;
          public          postgres    false    216            �            1259    25180    descriptivestatistics    TABLE     d  CREATE TABLE public.descriptivestatistics (
    percentile_10 double precision,
    percentile_25 double precision,
    percentile_50 double precision,
    percentile_75 double precision,
    percentile_90 double precision,
    mean double precision,
    max double precision,
    min double precision,
    iqr double precision,
    range double precision,
    variance double precision,
    standard double precision,
    kurtosis double precision,
    skewness double precision,
    n double precision,
    statistic_type text,
    basic_system text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 )   DROP TABLE public.descriptivestatistics;
       public         heap    postgres    false            �            1259    25344    descriptivestatistics_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.descriptivestatistics_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.descriptivestatistics_uid_seq;
       public          postgres    false    204            6           0    0    descriptivestatistics_uid_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.descriptivestatistics_uid_seq OWNED BY public.descriptivestatistics.uid;
          public          postgres    false    217            �            1259    25188    generalstatistics    TABLE       CREATE TABLE public.generalstatistics (
    current_time_start_format timestamp with time zone,
    current_time_end_format timestamp with time zone,
    client_counter integer,
    read_requests integer,
    write_requests integer,
    total_number_of_requests integer,
    exclude_failed_read_requests boolean,
    exclude_failed_write_requests boolean,
    failed_total integer,
    successful_total integer,
    number_of_workloads integer,
    complete_start_time_format timestamp with time zone,
    complete_end_time_format timestamp with time zone,
    total_runtime double precision,
    measurement_runtime double precision,
    rptu double precision,
    wptu double precision,
    fptu double precision,
    sptu double precision,
    tptu double precision,
    cpu_usage double precision,
    average_cpu_usage_per_core double precision,
    cumulative_count integer,
    conversion_type double precision,
    basic_system text,
    statistic_type text,
    notes text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 %   DROP TABLE public.generalstatistics;
       public         heap    postgres    false            �            1259    25356    generalstatistics_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.generalstatistics_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.generalstatistics_uid_seq;
       public          postgres    false    205            7           0    0    generalstatistics_uid_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.generalstatistics_uid_seq OWNED BY public.generalstatistics.uid;
          public          postgres    false    218            �            1259    25196    listenerstatisticobject    TABLE     b  CREATE TABLE public.listenerstatisticobject (
    start_time double precision,
    end_time double precision,
    latency double precision,
    is_invalid boolean,
    is_existing boolean,
    has_error boolean,
    is_valid boolean,
    client_id text,
    event_key text,
    obtained_events_total_map_size integer,
    obtained_events_map_size integer,
    invalid_value_counter integer,
    existing_value_counter integer,
    error_value_counter integer,
    valid_counter integer,
    set_threshold double precision,
    expected_threshold double precision,
    total_threshold double precision,
    cumulative_count integer,
    conversion double precision,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    start_time_format timestamp with time zone,
    end_time_format timestamp with time zone,
    uid integer NOT NULL
);
 +   DROP TABLE public.listenerstatisticobject;
       public         heap    postgres    false            �            1259    25922    listenerstatisticobject_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.listenerstatisticobject_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.listenerstatisticobject_uid_seq;
       public          postgres    false    206            8           0    0    listenerstatisticobject_uid_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.listenerstatisticobject_uid_seq OWNED BY public.listenerstatisticobject.uid;
          public          postgres    false    223            �            1259    25287    node_occupancy    TABLE     �   CREATE TABLE public.node_occupancy (
    node text NOT NULL,
    used_by_counter integer DEFAULT 0 NOT NULL,
    run_id text NOT NULL,
    uid integer NOT NULL
);
 "   DROP TABLE public.node_occupancy;
       public         heap    postgres    false            �            1259    25310    node_occupancy_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.node_occupancy_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.node_occupancy_uid_seq;
       public          postgres    false    213            9           0    0    node_occupancy_uid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.node_occupancy_uid_seq OWNED BY public.node_occupancy.uid;
          public          postgres    false    214            �            1259    25204    quorum_nonce    TABLE     �   CREATE TABLE public.quorum_nonce (
    address text NOT NULL,
    nonce integer DEFAULT 0 NOT NULL,
    uid integer NOT NULL
);
     DROP TABLE public.quorum_nonce;
       public         heap    postgres    false            �            1259    25211    quorum_nonce_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.quorum_nonce_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.quorum_nonce_uid_seq;
       public          postgres    false    207            :           0    0    quorum_nonce_uid_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.quorum_nonce_uid_seq OWNED BY public.quorum_nonce.uid;
          public          postgres    false    208            �            1259    25213    readstatisticobject    TABLE     �  CREATE TABLE public.readstatisticobject (
    start_time_format timestamp with time zone,
    end_time_format timestamp with time zone,
    start_time double precision,
    end_time double precision,
    latency double precision,
    request_id_of_workload text,
    client_id text,
    request_number integer,
    failed_request boolean,
    payload_type text,
    error_messages text,
    had_error boolean,
    participating_servers text,
    cumulative_count integer,
    conversion double precision,
    is_consistent boolean,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    specific_payload_types text,
    number_of_error_messages integer,
    uid integer NOT NULL
);
 '   DROP TABLE public.readstatisticobject;
       public         heap    postgres    false            �            1259    26071    readstatisticobject_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.readstatisticobject_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.readstatisticobject_uid_seq;
       public          postgres    false    209            ;           0    0    readstatisticobject_uid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.readstatisticobject_uid_seq OWNED BY public.readstatisticobject.uid;
          public          postgres    false    225            �            1259    25221    systemstatistics    TABLE       CREATE TABLE public.systemstatistics (
    os_name text,
    os_arch text,
    os_version text,
    os_number_of_cores integer,
    jvm_available_processors integer,
    os_total_memory text,
    os_free_physical_memory_size text,
    os_total_swap_space_size text,
    os_free_swap_space_size text,
    os_committed_virtual_memory_size text,
    jvm_total_memory text,
    jvm_available_memory text,
    jvm_max_memory text,
    jvm_free_memory text,
    jvm_used_memory text,
    os_system_cpu_load double precision,
    os_process_cpu_load double precision,
    os_process_cpu_time double precision,
    os_system_load_average double precision,
    cumulative_count integer,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 $   DROP TABLE public.systemstatistics;
       public         heap    postgres    false            �            1259    25389    systemstatistics_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.systemstatistics_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.systemstatistics_uid_seq;
       public          postgres    false    210            <           0    0    systemstatistics_uid_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.systemstatistics_uid_seq OWNED BY public.systemstatistics.uid;
          public          postgres    false    219            �            1259    25229    workloadpoolstatistics    TABLE     ]  CREATE TABLE public.workloadpoolstatistics (
    complete_start_time_before_rate_limiter_format timestamp with time zone,
    complete_start_time_format timestamp with time zone,
    complete_end_time_format timestamp with time zone,
    total_runtime double precision,
    total_runtime_before_rate_limiter double precision,
    workload_id integer,
    client_id text,
    read_requests integer,
    write_requests integer,
    total_number_of_requests integer,
    exclude_failed_read_requests boolean,
    exclude_failed_write_requests boolean,
    failed_total integer,
    successful_total integer,
    rptu double precision,
    wptu double precision,
    fptu double precision,
    sptu double precision,
    tptu double precision,
    cpu_usage_before_rate_limiter double precision,
    average_cpu_usage_per_core_before_rate_limiter double precision,
    cpu_usage double precision,
    average_cpu_usage_per_core double precision,
    cumulative_count integer,
    conversion_type double precision,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    uid integer NOT NULL
);
 *   DROP TABLE public.workloadpoolstatistics;
       public         heap    postgres    false            �            1259    25401    workloadpoolstatistics_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.workloadpoolstatistics_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.workloadpoolstatistics_uid_seq;
       public          postgres    false    211            =           0    0    workloadpoolstatistics_uid_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.workloadpoolstatistics_uid_seq OWNED BY public.workloadpoolstatistics.uid;
          public          postgres    false    220            �            1259    25237    writestatisticobject    TABLE     �  CREATE TABLE public.writestatisticobject (
    start_time_format timestamp with time zone,
    end_time_format timestamp with time zone,
    start_time double precision,
    end_time double precision,
    latency double precision,
    request_id_of_workload text,
    client_id text,
    request_number integer,
    failed_request boolean,
    payload_type text,
    error_messages text,
    had_error boolean,
    participating_servers text,
    cumulative_count integer,
    conversion double precision,
    is_consistent boolean,
    basic_system text,
    statistic_type text,
    cid text,
    run_id text,
    specific_payload_types text,
    associated_events text,
    number_of_error_messages integer,
    uid integer NOT NULL
);
 (   DROP TABLE public.writestatisticobject;
       public         heap    postgres    false            �            1259    26060    writestatisticobject_uid_seq    SEQUENCE     �   CREATE SEQUENCE public.writestatisticobject_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.writestatisticobject_uid_seq;
       public          postgres    false    212            >           0    0    writestatisticobject_uid_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.writestatisticobject_uid_seq OWNED BY public.writestatisticobject.uid;
          public          postgres    false    224            �           2604    25548    blockstatisticobject uid    DEFAULT     �   ALTER TABLE ONLY public.blockstatisticobject ALTER COLUMN uid SET DEFAULT nextval('public.blockstatisticobject_uid_seq'::regclass);
 G   ALTER TABLE public.blockstatisticobject ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    222    221            z           2604    25245    clientcoordination uid    DEFAULT     �   ALTER TABLE ONLY public.clientcoordination ALTER COLUMN uid SET DEFAULT nextval('public.clientcoordination_uid_seq'::regclass);
 E   ALTER TABLE public.clientcoordination ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    201    200            {           2604    25324    clientexecutorstatistics uid    DEFAULT     �   ALTER TABLE ONLY public.clientexecutorstatistics ALTER COLUMN uid SET DEFAULT nextval('public.clientexecutorstatistics_uid_seq'::regclass);
 K   ALTER TABLE public.clientexecutorstatistics ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    215    202            |           2604    25335    customstatisticobject uid    DEFAULT     �   ALTER TABLE ONLY public.customstatisticobject ALTER COLUMN uid SET DEFAULT nextval('public.customstatisticobject_uid_seq'::regclass);
 H   ALTER TABLE public.customstatisticobject ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    216    203            }           2604    25346    descriptivestatistics uid    DEFAULT     �   ALTER TABLE ONLY public.descriptivestatistics ALTER COLUMN uid SET DEFAULT nextval('public.descriptivestatistics_uid_seq'::regclass);
 H   ALTER TABLE public.descriptivestatistics ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    217    204            ~           2604    25358    generalstatistics uid    DEFAULT     ~   ALTER TABLE ONLY public.generalstatistics ALTER COLUMN uid SET DEFAULT nextval('public.generalstatistics_uid_seq'::regclass);
 D   ALTER TABLE public.generalstatistics ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    218    205                       2604    25924    listenerstatisticobject uid    DEFAULT     �   ALTER TABLE ONLY public.listenerstatisticobject ALTER COLUMN uid SET DEFAULT nextval('public.listenerstatisticobject_uid_seq'::regclass);
 J   ALTER TABLE public.listenerstatisticobject ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    223    206            �           2604    25312    node_occupancy uid    DEFAULT     x   ALTER TABLE ONLY public.node_occupancy ALTER COLUMN uid SET DEFAULT nextval('public.node_occupancy_uid_seq'::regclass);
 A   ALTER TABLE public.node_occupancy ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    214    213            �           2604    25251    quorum_nonce uid    DEFAULT     t   ALTER TABLE ONLY public.quorum_nonce ALTER COLUMN uid SET DEFAULT nextval('public.quorum_nonce_uid_seq'::regclass);
 ?   ALTER TABLE public.quorum_nonce ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    208    207            �           2604    26073    readstatisticobject uid    DEFAULT     �   ALTER TABLE ONLY public.readstatisticobject ALTER COLUMN uid SET DEFAULT nextval('public.readstatisticobject_uid_seq'::regclass);
 F   ALTER TABLE public.readstatisticobject ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    225    209            �           2604    25391    systemstatistics uid    DEFAULT     |   ALTER TABLE ONLY public.systemstatistics ALTER COLUMN uid SET DEFAULT nextval('public.systemstatistics_uid_seq'::regclass);
 C   ALTER TABLE public.systemstatistics ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    219    210            �           2604    25403    workloadpoolstatistics uid    DEFAULT     �   ALTER TABLE ONLY public.workloadpoolstatistics ALTER COLUMN uid SET DEFAULT nextval('public.workloadpoolstatistics_uid_seq'::regclass);
 I   ALTER TABLE public.workloadpoolstatistics ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    220    211            �           2604    26062    writestatisticobject uid    DEFAULT     �   ALTER TABLE ONLY public.writestatisticobject ALTER COLUMN uid SET DEFAULT nextval('public.writestatisticobject_uid_seq'::regclass);
 G   ALTER TABLE public.writestatisticobject ALTER COLUMN uid DROP DEFAULT;
       public          postgres    false    224    212            �           2606    25257    quorum_nonce address 
   CONSTRAINT     R   ALTER TABLE ONLY public.quorum_nonce
    ADD CONSTRAINT address UNIQUE (address);
 >   ALTER TABLE ONLY public.quorum_nonce DROP CONSTRAINT address;
       public            postgres    false    207            �           2606    25556 .   blockstatisticobject blockstatisticobject_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.blockstatisticobject
    ADD CONSTRAINT blockstatisticobject_pkey PRIMARY KEY (uid);
 X   ALTER TABLE ONLY public.blockstatisticobject DROP CONSTRAINT blockstatisticobject_pkey;
       public            postgres    false    221            �           2606    25259 *   clientcoordination clientcoordination_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.clientcoordination
    ADD CONSTRAINT clientcoordination_pkey PRIMARY KEY (uid);
 T   ALTER TABLE ONLY public.clientcoordination DROP CONSTRAINT clientcoordination_pkey;
       public            postgres    false    200            �           2606    25332 6   clientexecutorstatistics clientexecutorstatistics_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.clientexecutorstatistics
    ADD CONSTRAINT clientexecutorstatistics_pkey PRIMARY KEY (uid);
 `   ALTER TABLE ONLY public.clientexecutorstatistics DROP CONSTRAINT clientexecutorstatistics_pkey;
       public            postgres    false    202            �           2606    25343 0   customstatisticobject customstatisticobject_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.customstatisticobject
    ADD CONSTRAINT customstatisticobject_pkey PRIMARY KEY (uid);
 Z   ALTER TABLE ONLY public.customstatisticobject DROP CONSTRAINT customstatisticobject_pkey;
       public            postgres    false    203            �           2606    25354 0   descriptivestatistics descriptivestatistics_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.descriptivestatistics
    ADD CONSTRAINT descriptivestatistics_pkey PRIMARY KEY (uid);
 Z   ALTER TABLE ONLY public.descriptivestatistics DROP CONSTRAINT descriptivestatistics_pkey;
       public            postgres    false    204            �           2606    25366 (   generalstatistics generalstatistics_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.generalstatistics
    ADD CONSTRAINT generalstatistics_pkey PRIMARY KEY (uid);
 R   ALTER TABLE ONLY public.generalstatistics DROP CONSTRAINT generalstatistics_pkey;
       public            postgres    false    205            �           2606    25932 4   listenerstatisticobject listenerstatisticobject_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.listenerstatisticobject
    ADD CONSTRAINT listenerstatisticobject_pkey PRIMARY KEY (uid);
 ^   ALTER TABLE ONLY public.listenerstatisticobject DROP CONSTRAINT listenerstatisticobject_pkey;
       public            postgres    false    206            �           2606    25298    node_occupancy node 
   CONSTRAINT     N   ALTER TABLE ONLY public.node_occupancy
    ADD CONSTRAINT node UNIQUE (node);
 =   ALTER TABLE ONLY public.node_occupancy DROP CONSTRAINT node;
       public            postgres    false    213            �           2606    25321 "   node_occupancy node_occupancy_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.node_occupancy
    ADD CONSTRAINT node_occupancy_pkey PRIMARY KEY (uid);
 L   ALTER TABLE ONLY public.node_occupancy DROP CONSTRAINT node_occupancy_pkey;
       public            postgres    false    213            �           2606    25271    quorum_nonce quorum_nonce_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.quorum_nonce
    ADD CONSTRAINT quorum_nonce_pkey PRIMARY KEY (uid);
 H   ALTER TABLE ONLY public.quorum_nonce DROP CONSTRAINT quorum_nonce_pkey;
       public            postgres    false    207            �           2606    26081 ,   readstatisticobject readstatisticobject_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.readstatisticobject
    ADD CONSTRAINT readstatisticobject_pkey PRIMARY KEY (uid);
 V   ALTER TABLE ONLY public.readstatisticobject DROP CONSTRAINT readstatisticobject_pkey;
       public            postgres    false    209            �           2606    25275    clientcoordination run_id 
   CONSTRAINT     V   ALTER TABLE ONLY public.clientcoordination
    ADD CONSTRAINT run_id UNIQUE (run_id);
 C   ALTER TABLE ONLY public.clientcoordination DROP CONSTRAINT run_id;
       public            postgres    false    200            �           2606    25399 &   systemstatistics systemstatistics_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.systemstatistics
    ADD CONSTRAINT systemstatistics_pkey PRIMARY KEY (uid);
 P   ALTER TABLE ONLY public.systemstatistics DROP CONSTRAINT systemstatistics_pkey;
       public            postgres    false    210            �           2606    25411 2   workloadpoolstatistics workloadpoolstatistics_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.workloadpoolstatistics
    ADD CONSTRAINT workloadpoolstatistics_pkey PRIMARY KEY (uid);
 \   ALTER TABLE ONLY public.workloadpoolstatistics DROP CONSTRAINT workloadpoolstatistics_pkey;
       public            postgres    false    211            �           2606    26070 .   writestatisticobject writestatisticobject_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.writestatisticobject
    ADD CONSTRAINT writestatisticobject_pkey PRIMARY KEY (uid);
 X   ALTER TABLE ONLY public.writestatisticobject DROP CONSTRAINT writestatisticobject_pkey;
       public            postgres    false    212            �           2620    25282 )   clientcoordination client_counter_trigger    TRIGGER     �   CREATE TRIGGER client_counter_trigger AFTER INSERT OR UPDATE ON public.clientcoordination FOR EACH ROW EXECUTE FUNCTION public.client_counter();
 B   DROP TRIGGER client_counter_trigger ON public.clientcoordination;
       public          postgres    false    200    226           