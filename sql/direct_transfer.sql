CREATE OR REPLACE FUNCTION get_direct_routes(
    start_point TEXT,
    end_point TEXT
) RETURNS TABLE(
	id integer,
	geom geometry,
	route_code varchar,
	route varchar,
	type varchar,
	service_class varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
		f.id,
        st_linesubstring(
            f.geom,
            st_linelocatepoint(f.geom, st_geometryfromtext('POINT(' || start_point || ')', 4326)),
            st_linelocatepoint(f.geom, st_geometryfromtext('POINT(' || end_point || ')', 4326))
        ) as geom,
		f."codigo_de_ruta",
		f."ruta",
		f."tipo_de_transporte",
		f."clase_de_servicio"
    FROM get_filtered_direct_routes(start_point, end_point) f;
END;
$$ LANGUAGE plpgsql;
