--liquibase formatted sql

--This is for the sedmap schema
 
--changeset ajmccart:CreateSiteTable
CREATE TABLE SEDMAP.SITE_REF
(
  SITE_NO             VARCHAR2(255 BYTE),
  SNAME               VARCHAR2(255 BYTE),
  LATITUDE            VARCHAR2(255 BYTE),
  LONGITUDE           VARCHAR2(255 BYTE),
  GEOM_LL             MDSYS.SDO_GEOMETRY,
  NWISDA1             number(11,4),
  STATE               VARCHAR2(255 BYTE),
  COUNTY_NAME         VARCHAR2(255 BYTE),
  ECO_L3_CODE         VARCHAR2(255 BYTE),
  ECO_L3_NAME         VARCHAR2(255 BYTE),
  ECO_L2_CODE         VARCHAR2(255 BYTE),
  ECO_L2_NAME         VARCHAR2(255 BYTE),
  ECO_L1_NAME         VARCHAR2(255 BYTE),
  ECO_L1_CODE         VARCHAR2(255 BYTE),
  HUC_REGION_NAME     VARCHAR2(255 BYTE),
  HUC_SUBREGION_NAME  VARCHAR2(255 BYTE),
  HUC_BASIN_NAME      VARCHAR2(255 BYTE),
  HUC_SUBBASIN_NAME   VARCHAR2(255 BYTE),
  HUC_2               VARCHAR2(255 BYTE),
  HUC_4               VARCHAR2(255 BYTE),
  HUC_6               VARCHAR2(255 BYTE),
  HUC_8               VARCHAR2(255 BYTE),
  PERM                number( 6,4),
  BFI                 number( 6,4),
  KFACT               number( 5,4),
  RFACT               number( 8,5),
  PPT30               number( 7,4),
  URBAN               number(12,9),
  FOREST              number(12,9),
  AGRIC               number(12,9),
  MAJ_DAMS            number( 7,4),
  NID_STOR            number(13,4),
  CLAY                number( 6,4),
  SAND                number( 6,4),
  SILT                number( 6,4),
  GAGE                VARCHAR2(1 BYTE)
);

ALTER TABLE SEDMAP.SITE_REF ADD (
  CONSTRAINT SITE_REF_PK
  PRIMARY KEY
  (SITE_NO));
  
GRANT SELECT ON SEDMAP.SITE_REF TO SEDUSER;

 --rollback Drop table SITE_REF;
 
 --changeset ajmccart:AddtoMetadataView
INSERT INTO mdsys.user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES ('SITE_REF',
          'GEOM_LL',
          mdsys.SDO_DIM_ARRAY(
          mdsys.SDO_DIM_ELEMENT('X', -180, 180, 0.005), 
          mdsys.SDO_DIM_ELEMENT('Y', -90, 90, 0.005)
          ),
          8307);
--rollback delete from mdsys.user_sdo_geom_metadata where table_name='SITE_REF';

--changeset ajmccart:spatialIndex
CREATE INDEX SM_SITE_GEOM_LL_SP_IDX
   ON "SITE_REF"("GEOM_LL") INDEXTYPE IS
   MDSYS.SPATIAL_INDEX PARAMETERS (' SDO_INDX_DIMS=2 LAYER_GTYPE="POINT"');
--rollback DROP INDEX SM_SITE_GEOM_LL_SP_IDX;


--changeset ajmccart:PopulateSiteTable
 insert into site_ref 
(SITE_NO,
  SNAME,
  LATITUDE,
  LONGITUDE,
  GEOM_LL,
  NWISDA1,
  STATE,
  COUNTY_NAME,
  ECO_L3_CODE,
  ECO_L3_NAME,
  ECO_L2_CODE,
  ECO_L2_NAME,
  ECO_L1_NAME,
  ECO_L1_CODE,
  HUC_REGION_NAME,
  HUC_SUBREGION_NAME,
  HUC_BASIN_NAME,
  HUC_SUBBASIN_NAME ,
  HUC_2,
  HUC_4,
  HUC_6,
  HUC_8,
  PERM,
  BFI,
  KFACT,
  RFACT ,
  PPT30 ,
  URBAN ,
  FOREST,
  AGRIC ,
  MAJ_DAMS,
  NID_STOR ,
  CLAY  ,
  SAND ,
  SILT,
  GAGE)  
select site_no,
  sname ,
  lat   ,
  "LONG"  ,
  NULL,
  to_number(nwisda1),
  state_name ,
  county_name ,
  ECO_L3_CODE,
  ECO_L3_NAME,
  ECO_L2_CODE,
  ECO_L2_NAME,
  ECO_L1_NAME,
  ECO_L1_CODE,
  HUC_REGION_NAME,
  HUC_SUBREGION_NAME,
  HUC_BASIN_NAME ,
  HUC_SUBBASIN_NAME ,
  HUC2,
  HUC4,
  HUC6,
  HUC8,
  PERM ,
  BFI  ,
  to_number(KFACT),
  to_number(RFACT) ,
  to_number(PPT30) ,
  to_number(URBAN) ,
  to_number(FOREST),
  to_number(AGRIC) ,
  to_number(MAJ_DAMS),
  to_number(NID_STOR) ,
  to_number(CLAY)  ,
  to_number(SAND) ,
  to_number(SILT),
  GAGE
   from SRC_SSC_SITE_INFO_11152017;

update site_ref set GEOM_LL = mdsys.sdo_geometry(2001,8307,mdsys.sdo_point_type
(longitude,latitude,null),null,null); 
--rollback truncate table site_ref;
