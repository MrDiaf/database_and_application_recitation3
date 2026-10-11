
CREATE TABLE star (
    id integer NOT NULL PRIMARY KEY,
    hip integer,
    hd integer,
    hr integer,
    gliese text,
    bayer_flamsteed text,
    proper_name text,
    ra_hours double precision,
    ra_deg double precision,
    dec_deg double precision,
    dist_pc double precision,
    pm_ra_mas_yr double precision,
    pm_dec_mas_yr double precision,
    rv_km_s double precision,
    mag double precision,
    abs_mag double precision,
    spectral_type text,  -- spectral_type: a code for temperature and size. The letter gives temperature, running O, B, A, F, G, K, M from hottest (blue) to coolest (red); the Sun is G. The Roman numeral gives size: V is an ordinary dwarf like the Sun, III a giant, I a supergiant. Betelgeuse is M1Iab, a cool red supergiant.
    color_index double precision,
    x_pc double precision,
    y_pc double precision,
    z_pc double precision,
    bayer text,
    flamsteed integer,
    con character varying(3),
    comp integer,
    comp_primary integer,
    base text,
    lum double precision,
    var text,
    var_min double precision,
    var_max double precision,
    naked_eye boolean GENERATED ALWAYS AS ((mag <= (6.5)::double precision)) STORED
);

CREATE TABLE dso (
    name text NOT NULL,
    type text NOT NULL,
    ra_deg double precision,
    dec_deg double precision,
    con character varying(3),
    maj_axis_arcmin double precision,
    min_axis_arcmin double precision,
    pos_angle integer,
    b_mag double precision,
    v_mag double precision,
    j_mag double precision,
    h_mag double precision,
    k_mag double precision,
    surf_brightness double precision,
    hubble_type text,
    parallax_mas double precision,
    pm_ra_mas_yr double precision,
    pm_dec_mas_yr double precision,
    rad_vel_km_s double precision,
    redshift double precision,
    messier integer,
    ngc text,
    ic text,
    identifiers text,
    common_names text,
    ned_notes text,
    notes text
);

CREATE TABLE dso_type (
    code text NOT NULL,
    description text NOT NULL
);

CREATE TABLE exoplanet (
    star_id integer,
    hip integer,
    hd integer,
    name text NOT NULL,
    host_name text NOT NULL,
    hip_name text,
    hd_name text,
    gaia_id text,
    num_stars integer,
    num_planets integer,
    discovery_method text,
    discovery_year integer,
    discovery_facility text,
    orbital_period_days double precision,
    semi_major_axis_au double precision,
    eccentricity double precision,
    radius_earth double precision,
    radius_jupiter double precision,
    mass_earth double precision,
    mass_jupiter double precision,
    eq_temp_k double precision,
    insolation_earth double precision,
    host_spectral_type text,
    host_teff_k double precision,
    host_radius_sun double precision,
    host_mass_sun double precision,
    host_metallicity double precision,
    host_age_gyr double precision,
    archive_updated text
);

CREATE TABLE constellation (
    abbr character varying(3) NOT NULL,
    name text NOT NULL
);

CREATE TABLE constellation_boundary (
    id integer NOT NULL,
    con character varying(3) NOT NULL,
    equinox text NOT NULL,
    part integer NOT NULL,
    boundary polygon NOT NULL,
    CONSTRAINT constellation_boundary_equinox_check CHECK ((equinox = ANY (ARRAY['B1875'::text, 'J2000'::text])))
);

CREATE TABLE constellation_line (
    id serial NOT NULL,
    con character varying(3) NOT NULL,
    strip integer NOT NULL,
    ra1_deg double precision,
    dec1_deg double precision,
    ra2_deg double precision,
    dec2_deg double precision,
    star1_id integer,
    star2_id integer
);

CREATE FUNCTION j2000_to_b1875(ra_deg double precision, dec_deg double precision) RETURNS point
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    AS $$
  WITH v AS (SELECT cosd(dec_deg)*cosd(ra_deg) x, cosd(dec_deg)*sind(ra_deg) y, sind(dec_deg) z),
       r AS (SELECT 0.999535927*x + 0.0279353071*y + 0.012146982*z AS x,
                    -0.0279353057*x + 0.999609719*y + -0.000169823591*z AS y,
                    -0.0121469853*x + -0.000169584874*y + 0.999926208*z AS z FROM v)
  SELECT point(mod((atan2d(y, x) + 360)::numeric, 360)::float8, asind(greatest(-1, least(1, z)))) FROM r
$$;

CREATE FUNCTION constellation_at(ra_deg double precision, dec_deg double precision) RETURNS character varying
    LANGUAGE sql STABLE PARALLEL SAFE
    AS $$
  SELECT con FROM constellation_boundary
   WHERE equinox = 'B1875' AND boundary @> j2000_to_b1875(ra_deg, dec_deg)
   ORDER BY con LIMIT 1
$$;

CREATE OR REPLACE FUNCTION make_galaxy() RETURNS integer AS $$
DECLARE
    name varchar(20) = substr(md5(random()::text), 0, 8);
    ra_deg real := floor(random()*360+1);
    dec_deg real := floor(random()*180-90);
    redshift real := random();
    notes text := 'simulated';
BEGIN
    INSERT INTO dso (name,type,ra_deg,dec_deg,redshift,notes,con)
      VALUES (name, 'G',ra_deg,dec_deg,redshift,notes,constellation_at(ra_deg,dec_deg));
    --RAISE NOTICE 'Galaxy:%',name;
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION make_galaxies(size int) RETURNS integer AS $$
DECLARE
    i int := 0;
    rv int := 0;
BEGIN
    LOOP
        rv := (SELECT make_galaxy());
        EXIT WHEN (i > size);
        i := i + 1;
    END LOOP;
    RETURN i;
END;
$$ LANGUAGE plpgsql;