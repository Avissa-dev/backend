select * from avs_streets;

select * from amss_calles;


insert into avs_streets (str_id, str_name, geom)
  select fid, name, geom 
    from amss_calles;
    
select * from amss_rutas order by "Codigo_de_Ruta";

select distinct "Tipo_de_Transporte" from amss_rutas;

select * from avs_route_classes arc ;

delete from avs_route_classes arc where cls_id > 2;

insert into avs_route_classes (cls_id, cls_name)
  select distinct nextval('avs_cls_seq'), "Clase_de_Servicio" from amss_rutas;
 
insert into avs_route_types (rty_id, rty_description)
  values (1, 'AUTOBUS');
 
insert into avs_route_types (rty_id, rty_description)
  values (2, 'MICROBUS');
 
alter table avs_routes add column rot_descripcion varchar(200);
 
insert into avs_routes (rot_id, rot_name, rot_code, rot_descripcion, rty_id, cls_id)
  select nextval('avs_rot_seq'), t.ruta, t.codigo, t.descrip, t.tipo, t.clase
     from (select distinct "Ruta" ruta, "Codigo_de_Ruta" codigo, "Denominacion" descrip, case when "Tipo_de_Transporte" like '%AUTOBU%' then 1 else 2 end as tipo, case when "Clase_de_Servicio" like 'ORD%' then 1 else 2 end as clase
              from amss_rutas) as t;
 
insert into avs_directions values (1, 'Ida');
insert into avs_directions values (2, 'Regreso');
             

insert into avs_route_paths (rtp_id, geom, rot_id, dir_id)
  select nextval('avs_rtp_seq'), geom, (select rot_id from avs_routes rot where rot.rot_code = rdt."Codigo_de_Ruta" and rot.rot_name = rdt."Ruta"), case when "Sentido" = 'Ida' then 1 else 2 end
    from amss_rutas rdt;
    
