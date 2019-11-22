--liquibase formatted sql

--This is for the sedmap schema

--changeset ajmccart:CreateSiteBasinTable
create table site_basin (
  SITE_NO varchar2(15),
  BASIN_IDS varchar2(1000)
);
alter table site_basin add constraint 
site_basin_pk primary key(SITE_NO);
grant select on site_basin to seduser;
-- rollback drop table site_basin;


--changeset ajmccart:PopulateSiteBasinTable
insert into site_basin
select site_no,
basin_ids
from SRC_SEDMAP_SITE_BASIN_111419;
-- rollback truncate table site_basin;
