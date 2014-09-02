--liquibase formatted sql

--This is for the sedmap schema
 
--changeset ajmccart:CreatePoulateFlowExceedance
CREATE TABLE SEDMAP.FLOW_EXCEEDANCE
(
  SITE_NO  VARCHAR2(255 BYTE),
  NHDP1    VARCHAR2(255 BYTE),
  NHDP5    VARCHAR2(255 BYTE),
  NHDP10   VARCHAR2(255 BYTE),
  NHDP20   VARCHAR2(255 BYTE),
  NHDP25   VARCHAR2(255 BYTE),
  NHDP30   VARCHAR2(255 BYTE),
  NHDP40   VARCHAR2(255 BYTE),
  NHDP50   VARCHAR2(255 BYTE),
  NHDP60   VARCHAR2(255 BYTE),
  NHDP70   VARCHAR2(255 BYTE),
  NHDP75   VARCHAR2(255 BYTE),
  NHDP80   VARCHAR2(255 BYTE),
  NHDP90   VARCHAR2(255 BYTE),
  NHDP95   VARCHAR2(255 BYTE),
  NHDP99   VARCHAR2(255 BYTE)
);

ALTER TABLE SEDMAP.FLOW_EXCEEDANCE ADD (
  CONSTRAINT FLOW_EXCEEDANCE_R01 
  FOREIGN KEY (SITE_NO) 
  REFERENCES SEDMAP.SITE_REF (SITE_NO));
  
GRANT SELECT ON SEDMAP.FLOW_EXCEEDANCE TO SEDUSER;

insert into flow_exceedance
select "site_no",
  "nhdp1",
  "nhdp5",
  "nhdp10",
  "nhdp20",
  "nhdp25",
  "nhdp30",
  "nhdp40",
  "nhdp50",
  "nhdp60",
  "nhdp70",
  "nhdp75",
  "nhdp80",
  "nhdp90",
  "nhdp95",
  "nhdp99"
   from SRC_SSC_SITE_INFO_782014;
--rollback Drop table flow_exceedance;
