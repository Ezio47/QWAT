/*
 qWat - QGIS Water Module
 
 SQL file :: pipe table
*/

/* create */
DROP TABLE IF EXISTS distribution.pipe CASCADE;
CREATE TABLE distribution.pipe (id serial NOT NULL);
COMMENT ON TABLE distribution.pipe IS 'Table for pipe. This should not be used for editing/viewing, as a more complete view (pipe_view) exists.';
SELECT setval('distribution.pipe_id_seq', 35000, true);

/* columns */                                                                          
ALTER TABLE distribution.pipe ADD COLUMN id_parent           integer;                                      /* id_parent            FK */
ALTER TABLE distribution.pipe ADD COLUMN id_function         integer;                                      /* id_function          FK */ 
ALTER TABLE distribution.pipe ADD COLUMN id_installmethod    integer;                                      /* id_installmethod     FK */
ALTER TABLE distribution.pipe ADD COLUMN id_material         integer;                                      /* id_material          FK */
ALTER TABLE distribution.pipe ADD COLUMN id_distributor      integer;                                      /* id_distributor       FK */
ALTER TABLE distribution.pipe ADD COLUMN id_precision        integer;                                      /* id_precision         FK */
ALTER TABLE distribution.pipe ADD COLUMN id_protection       integer;                                      /* id_protection        FK */
ALTER TABLE distribution.pipe ADD COLUMN id_status           integer;                                      /* id_status            FK */
ALTER TABLE distribution.pipe ADD COLUMN id_labelview        integer default 2;                            /* label_view           FK */
ALTER TABLE distribution.pipe ADD COLUMN id_labelview_schema integer default 2;                            /* label_view_schema    FK */
ALTER TABLE distribution.pipe ADD COLUMN labelremark         varchar(150);                                 /* labelemark              */
ALTER TABLE distribution.pipe ADD COLUMN labelremark_schema  boolean default false;                        /* labelremark_schema      */
ALTER TABLE distribution.pipe ADD COLUMN year                smallint CHECK (year > 1800 AND year < 2100); /* year                    */
ALTER TABLE distribution.pipe ADD COLUMN tunnel_or_bridge    boolean default false;                        /* tunnel_or_bridge        */
ALTER TABLE distribution.pipe ADD COLUMN pressure_nominal    smallint default 16;                          /* pressure_nominale       */
ALTER TABLE distribution.pipe ADD COLUMN folder              varchar(20) default '';                       /* folder                  */
ALTER TABLE distribution.pipe ADD COLUMN remarks text        default '' ;                                  /* remarks                 */
ALTER TABLE distribution.pipe ADD COLUMN _valve_count        smallint default NULL;                        /* _valve_count            */
ALTER TABLE distribution.pipe ADD COLUMN _valve_closed       boolean default NULL;                         /* _valve_closed           */

/* schema view */
SELECT distribution.enable_schemaview( 'pipe', 'vl_pipe_function', 'id_function' );

/* geometry */
SELECT distribution.geom_tool_line('pipe');

/* old columns */
ALTER TABLE distribution.pipe ADD COLUMN coating_internal_material_id character(20);
ALTER TABLE distribution.pipe ADD COLUMN coating_external_material_id character(20);

/* Constraints */
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_pkey PRIMARY KEY (id);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_parent           FOREIGN KEY (id_parent)           REFERENCES distribution.pipe (id)                 MATCH SIMPLE ; CREATE INDEX fki_pipe_id_parent           ON distribution.pipe(id_parent);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_function         FOREIGN KEY (id_function)         REFERENCES distribution.vl_pipe_function(id)         MATCH FULL   ; CREATE INDEX fki_pipe_id_function         ON distribution.pipe(id_function);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_installmethod    FOREIGN KEY (id_installmethod)    REFERENCES distribution.vl_pipe_installmethod(id) MATCH FULL   ; CREATE INDEX fki_pipe_id_installmethod    ON distribution.pipe(id_installmethod);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_material         FOREIGN KEY (id_material)         REFERENCES distribution.vl_pipe_material(id)         MATCH FULL   ; CREATE INDEX fki_pipe_id_material         ON distribution.pipe(id_material);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_distributor      FOREIGN KEY (id_distributor)      REFERENCES distribution.distributor(id)           MATCH FULL   ; CREATE INDEX fki_pipe_id_distributor      ON distribution.pipe(id_distributor);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_precision        FOREIGN KEY (id_precision)        REFERENCES distribution.vl_precision(id)          MATCH FULL   ; CREATE INDEX fki_pipe_id_precision        ON distribution.pipe(id_precision);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_protection       FOREIGN KEY (id_protection)       REFERENCES distribution.vl_pipe_protection(id)       MATCH SIMPLE ; CREATE INDEX fki_pipe_id_protection       ON distribution.pipe(id_protection);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_status           FOREIGN KEY (id_status)           REFERENCES distribution.vl_status(id)             MATCH FULL   ; CREATE INDEX fki_pipe_id_status           ON distribution.pipe(id_status);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_labelview        FOREIGN KEY (id_labelview)        REFERENCES distribution.vl_labelview(id)          MATCH FULL   ; CREATE INDEX fki_pipe_id_labelview        ON distribution.pipe(id_labelview);
ALTER TABLE distribution.pipe ADD CONSTRAINT pipe_id_labelview_schema FOREIGN KEY (id_labelview_schema) REFERENCES distribution.vl_labelview(id)          MATCH FULL   ; CREATE INDEX fki_pipe_id_labelview_schema ON distribution.pipe(id_labelview_schema);


/*----------------!!!---!!!----------------*/
/* Trigger for tunnel_or_bridge */
CREATE OR REPLACE FUNCTION distribution.pipe_tunnelbridge() RETURNS trigger AS
$BODY$ 
 BEGIN
  UPDATE distribution.pipe SET _length3d = NULL, _diff_elevation = NULL WHERE id = NEW.id;
  RETURN NEW;
 END;
$BODY$ LANGUAGE 'plpgsql';

CREATE TRIGGER pipe_tunnelbridge_trigger
 AFTER INSERT OR UPDATE OF tunnel_or_bridge ON distribution.pipe
 FOR EACH ROW EXECUTE PROCEDURE distribution.pipe_tunnelbridge();
COMMENT ON TRIGGER pipe_tunnelbridge_trigger ON distribution.pipe IS 'For tunnel and bridges, 3d length is the 2d length (i.e. pipes are considered as horinzontal).';







