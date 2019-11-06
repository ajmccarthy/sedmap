--liquibase formatted sql

--This is for the sedmap schema

--changeset ajmccart:CreatePopulateDiscreteSites
CREATE TABLE SEDMAP.DISCRETE_SITES
(
  SITE_NO  VARCHAR2(255 BYTE)
);

ALTER TABLE SEDMAP.DISCRETE_SITES ADD (
  CONSTRAINT DISCRETE_SITES_PK
  PRIMARY KEY
  (SITE_NO));
  
ALTER TABLE SEDMAP.DISCRETE_SITES ADD (
  CONSTRAINT DISCRETE_SITES_R01 
  FOREIGN KEY (SITE_NO) 
  REFERENCES SEDMAP.SITE_REF (SITE_NO));
  
GRANT SELECT ON SEDMAP.DISCRETE_SITES TO SEDUSER;

insert into discrete_sites
select distinct site_no from SRC_DISCUPDATE_2019;
--rollback Drop table discrete_sites;


--changeset ajmccart:CreatePopulateDiscreteSample
CREATE TABLE SEDMAP.DISCRETE_SAMPLE_FACT
(
  SITE_NO        VARCHAR2(255 BYTE),
  STATION_NM     VARCHAR2(255 BYTE),
  DATETIME       date,
  DCOMMENT       VARCHAR2(255 BYTE),
  ICOMMENT       VARCHAR2(255 BYTE),
  SSC            VARCHAR2(255 BYTE),
  DAILYFLOW      VARCHAR2(255 BYTE),
  INSTFLOW       VARCHAR2(255 BYTE),
  GH             VARCHAR2(255 BYTE),
  P2             VARCHAR2(255 BYTE),
  P4             VARCHAR2(255 BYTE),
  P8             VARCHAR2(255 BYTE),
  P16            VARCHAR2(255 BYTE),
  P31            VARCHAR2(255 BYTE),
  P63            VARCHAR2(255 BYTE),
  P125           VARCHAR2(255 BYTE),
  P250           VARCHAR2(255 BYTE),
  P500           VARCHAR2(255 BYTE),
  P1MILLI        VARCHAR2(255 BYTE),
  P2MILLI        VARCHAR2(255 BYTE),
  LOI            VARCHAR2(255 BYTE),
  TSS            VARCHAR2(255 BYTE),
  SS             VARCHAR2(255 BYTE),
  AGENCYCODE     VARCHAR2(255 BYTE),
  SAMPMETHOD     VARCHAR2(255 BYTE),
  SAMPLEPURPOSE  VARCHAR2(255 BYTE),
  SAMPTYPE       VARCHAR2(255 BYTE),
  NUMBERSAMPPTS  VARCHAR2(255 BYTE),
  WIDTH          VARCHAR2(255 BYTE),
  VELOCITY       VARCHAR2(255 BYTE),
  TURB70         VARCHAR2(255 BYTE),
  TURB76         VARCHAR2(255 BYTE),
  TURB61028      VARCHAR2(255 BYTE),
  TURB63675      VARCHAR2(255 BYTE),
  TURB63676      VARCHAR2(255 BYTE),
  TURB63680      VARCHAR2(255 BYTE),
  TEMPC          VARCHAR2(255 BYTE),
  TEMPAIRC       VARCHAR2(255 BYTE),
  SC             VARCHAR2(255 BYTE),
  SCLAB          VARCHAR2(255 BYTE),
  DSS            VARCHAR2(255 BYTE),
  PH             VARCHAR2(255 BYTE),
  PHLAB          VARCHAR2(255 BYTE),
  END_DATE       date,
  END_TIME       VARCHAR2(5 BYTE));

 ALTER TABLE SEDMAP.DISCRETE_SAMPLE_FACT ADD (
  CONSTRAINT DISCRETE_SAMPLE_FACT_U01
  UNIQUE (SITE_NO, DATETIME)); 
  
ALTER TABLE SEDMAP.DISCRETE_SAMPLE_FACT ADD (
  CONSTRAINT DISCRETE_SAMPLE_FACT_R01 
  FOREIGN KEY (SITE_NO) 
  REFERENCES SEDMAP.DISCRETE_SITES (SITE_NO));

  
GRANT SELECT ON SEDMAP.DISCRETE_SAMPLE_FACT TO SEDUSER;
  

insert into discrete_sample_fact
select
site_no,
  station_nm,
  TO_DATE(datetime,  'YYYY-MM-DD HH24:MI:SS'),
  dcomment,
  icomment,
  SSC ,
  Dailyflow,
  Instflow,
  GH,
  P2,
  P4,
  P8 ,
  P16,
  P31,
  P63,
  P125,
  P250,
  P500,
  P1milli,
  P2milli,
  LOI,
  TSS,
  SS ,
  Agencycode,
  Sampmethod,
  Samplepurpose,
  Samptype,
  Numbersamppts,
  Width ,
  Velocity,
  Turb70,
  Turb76,
  Turb61028,
  Turb63675,
  Turb63676,
  Turb63680,
  TempC,
  TempairC,
  SC,
  Sclab,
  DSS ,
  pH,
  pHlab,
  TO_DATE(end_date, 'YYYY-MM-DD'),
  end_time 
   from SRC_DISCUPDATE_2019;

--rollback Drop table discrete_sample_fact;  
