create sequence avs_str_seq start with 1 increment by 1;
create sequence avs_rot_seq start with 1 increment by 1;
create sequence avs_rtp_seq start with 1 increment by 1;
create sequence avs_rts_seq start with 1 increment by 1;
create sequence avs_rty_seq start with 1 increment by 1;
create sequence avs_mun_seq start with 1 increment by 1;
create sequence avs_dir_seq start with 1 increment by 1;
create sequence avs_cls_seq start with 1 increment by 1;


CREATE TABLE avs_streets (
  str_id integer PRIMARY KEY DEFAULT nextval('avs_str_seq'::regclass),
  str_name varchar(100),
  geom geometry(MultiLineString,32616)
);

CREATE TABLE avs_routes (
  rot_id integer PRIMARY KEY DEFAULT nextval('avs_rot_seq'::regclass),
  rot_name varchar(100),
  rot_code varchar(10),
  rty_id integer,
  cls_id integer
);

CREATE TABLE avs_routes_path (
  rtp_id integer PRIMARY KEY DEFAULT nextval('avs_rtp_seq'::regclass),
  geom geometry(MultiLineString,32616),
  rot_id integer,
  dir_id integer
);

CREATE TABLE avs_route_stops (
  rts_id integer PRIMARY KEY DEFAULT nextval('avs_rts_seq'::regclass),
  rtp_id integer,
  rts_sequence numeric(4),
  rts_name varchar(100),
  geom geometry(Point,32616),
  rts_type varchar(3)
);

CREATE TABLE avs_route_types (
  rty_id integer PRIMARY KEY DEFAULT nextval('avs_rtp_seq'::regclass),
  rty_description varchar(30)
);

CREATE TABLE avs_municipality (
  mun_id integer PRIMARY KEY DEFAULT nextval('avs_mun_seq'::regclass),
  mun_name varchar(100),
  geom geometry(MultiPolygon,32616)
);

CREATE TABLE avs_directions (
  dir_id integer PRIMARY KEY DEFAULT nextval('avs_dir_seq'::regclass),
  dir_name varchar(10)
);

CREATE TABLE avs_route_classes (
  cls_id integer PRIMARY KEY DEFAULT nextval('avs_cls_seq'::regclass),
  cls_name varchar(50)
);

ALTER TABLE avs_routes ADD FOREIGN KEY (rty_id) REFERENCES avs_route_types (rty_id);

ALTER TABLE avs_routes ADD FOREIGN KEY (cls_id) REFERENCES avs_route_classes (cls_id);

ALTER TABLE avs_routes_path ADD FOREIGN KEY (rot_id) REFERENCES avs_routes (rot_id);

ALTER TABLE avs_routes_path ADD FOREIGN KEY (dir_id) REFERENCES avs_directions (dir_id);

ALTER TABLE avs_route_stops ADD FOREIGN KEY (rtp_id) REFERENCES avs_routes_path (rtp_id);

CREATE INDEX IF NOT EXISTS sidx_streets_geom
    ON public.avs_streets USING gist
    (geom)
    TABLESPACE pg_default;
	
CREATE INDEX IF NOT EXISTS sidx_routes_path_geom
    ON public.avs_routes_path USING gist
    (geom)
    TABLESPACE pg_default;
	
CREATE INDEX IF NOT EXISTS sidx_route_stops_geom
    ON public.avs_route_stops USING gist
    (geom)
    TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS sidx_municipality_geom
    ON public.avs_municipality USING gist
    (geom)
    TABLESPACE pg_default;
