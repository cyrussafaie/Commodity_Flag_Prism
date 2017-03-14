/*For each run dates need to be updated*/


/*statement 1: item-division level pricing */
-- region
create temp table a_tabl as
select 
--p.prod_stat_desc, count (distinct p.div_nbr ||p.prod_nbr) 
p.div_nbr ||p.prod_nbr as div_prod_combo,
p.div_nbr,
p.prod_nbr,
d.div_nm,
pim_prod_desc_lng, 
prc_uom, 
net_wt, 
sls_pack_size, 
ctch_wt_ind, 
prod_brnd, 
pim_brnd_nm, 
prod_lbl, 
pim_brnd_typ_desc, 
brk_ind, 
cmdty_ind, 
prod_shlf_life, 
prod_stat_desc, 
pim_usf_mfr_nm, 
pim_cls_desc, 
pim_ctgry_desc, 
pim_grp_desc, 
p.prod_rsrvbl_ind,

sum(s.qty_ship) as ttl_qty_cs,
count(distinct s.cust_nbr) as cust_cnt,
ttl_qty_cs/cust_cnt as cs_per_cust,
ttl_qty_cs/13 as ave_cs_per_wk,
sum (s.grs_sls_extnd) as ttl_sales,
ttl_sales/13 as wkly_sales

from prcmuser_usf_product p


left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 
)s

on s.prod_nbr= p.prod_nbr
and s.div_nbr= p.div_nbr

left join  prcmuser_usf_division d
on p.div_nbr = d.div_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr

where 
p.prod_rsrvbl_ind='Y' 
and p.prod_stat_desc in ('Seasonal (4A)','Seasonal (3A)','Out of Stock (2A)','Active (0A)')
and p.pim_mfr_prod_nbr not like '%F2F%'
and p.pim_prod_desc_lng not like '%F2F%'
and p.pim_cls_desc not in ('DISPOSABLES','EQUIPMENT & SUPPLIES','USDA (SCHOOL PROGRAMS)','UNKNOWN','ADMINISTRATIVE')
and p.inact_dt is null
and p.pim_brnd_typ_desc <>'CUSTOMER OWNED'
and p.prtry_item_ind = 'N'

--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 


and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

and  d.inact_dt is null
and d.cmpny_desc='USF BROADLINE'
and d.div_typ_desc='US FOODS'


group by 
div_prod_combo,
p.div_nbr,
p.prod_nbr,
pim_prod_desc_lng, 
prc_uom, 
net_wt, 
sls_pack_size, 
ctch_wt_ind, 
prod_brnd, 
pim_brnd_nm, 
prod_lbl, 
brk_ind, 
cmdty_ind, 
prod_shlf_life, 
prod_stat_desc, 
pim_usf_mfr_nm, 
pim_cls_desc, 
pim_ctgry_desc, 
pim_grp_desc, 
p.prod_rsrvbl_ind,
pim_brnd_typ_desc,
d.div_nm


order by ttl_qty_cs,cs_per_cust
;

-- endregion

/*statement 2a date calendar sales*/
-- region Weekly Sales
create temp table wkly_sls as
select 
--p.prod_stat_desc, count (distinct p.div_nbr ||p.prod_nbr) 
p.div_nbr ||p.prod_nbr as div_prod_combo,
p.div_nbr,
p.prod_nbr,
m.fisc_yr_wk,
sum(s.lic_prod_extnd)/sum (s.unfrm_qty_ship) as lpc,
sum(s.mkt_tot_extnd)/sum (s.unfrm_qty_ship) as TMC
 

from prcmuser_usf_product p


left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 

)s
on s.prod_nbr= p.prod_nbr
and s.div_nbr= p.div_nbr

left join  prcmuser_usf_division d
on p.div_nbr = d.div_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr
	
--left join daily_calendar_map m
--	on m.dt= s.prcs_dt

left join prcmuser_usf_calendar m
	on m.clndr_dt= s.prcs_dt
	
where 
p.prod_rsrvbl_ind='Y' 
and p.prod_stat_desc in ('Seasonal (4A)','Seasonal (3A)','Out of Stock (2A)','Active (0A)')
and p.pim_mfr_prod_nbr not like '%F2F%'
and p.pim_prod_desc_lng not like '%F2F%'
and p.pim_cls_desc not in ('DISPOSABLES','EQUIPMENT & SUPPLIES','USDA (SCHOOL PROGRAMS)','UNKNOWN','ADMINISTRATIVE')
and p.inact_dt is null
and p.pim_brnd_typ_desc <>'CUSTOMER OWNED'
and p.prtry_item_ind = 'N'

--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 


and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

and  d.inact_dt is null
and d.cmpny_desc='USF BROADLINE'
and d.div_typ_desc='US FOODS'


group by 
div_prod_combo,
p.div_nbr,
p.prod_nbr,
m.fisc_yr_wk
;
-- endregion


/*statement 2:division level data*/
-- region Division level sales
create temp table b_tabl as
select 
p.div_nbr,
d.div_nm,

sum(s.qty_ship) as ttl_qty_cs_div,
count(distinct s.cust_nbr) as cust_cnt_div,
ttl_qty_cs_div/cust_cnt_div as cs_per_cust_div,
ttl_qty_cs_div/13 as ave_cs_per_wk_div,
sum (s.grs_sls_extnd) as ttl_sales_div,
ttl_sales_div/13 as wkly_sales_div


from prcmuser_usf_product p


left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 

)s
on s.prod_nbr= p.prod_nbr
and s.div_nbr= p.div_nbr

left join  prcmuser_usf_division d
on p.div_nbr = d.div_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr

where 
p.prod_rsrvbl_ind='Y' 
and p.prod_stat_desc in ('Seasonal (4A)','Seasonal (3A)','Out of Stock (2A)','Active (0A)')
and p.pim_mfr_prod_nbr not like '%F2F%'
and p.pim_prod_desc_lng not like '%F2F%'
and p.pim_cls_desc not in ('DISPOSABLES','EQUIPMENT & SUPPLIES','USDA (SCHOOL PROGRAMS)','UNKNOWN','ADMINISTRATIVE')
and p.inact_dt is null
and p.pim_brnd_typ_desc <>'CUSTOMER OWNED'
and p.prtry_item_ind = 'N'

--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 


and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

and  d.inact_dt is null
and d.cmpny_desc='USF BROADLINE'
and d.div_typ_desc='US FOODS'


group by 
d.div_nm,
p.div_nbr
;
-- endregion


/*statement 3: price elasticity for all items*/
-- region Price Elasticity- All items
create temp table elast as 
select div_nbr,prod_nbr,round(sum(elasticity_weighted)/sum(qty),4) as weighted_elasticity  from( 
select p.div_nbr,p.prod_nbr, din.cust_nbr, din.elasticity2percent, sum(s.unfrm_qty_ship) as qty, qty*din.elasticity2percent as elasticity_weighted 
from dinesh_Customer_recs_Peihao_AllDivisions_20161119 din

left join prcmuser_usf_product p
on p.pim_usf_std_prod_cd= din.pim_usf_std_prod_cd
and din.div_nbr= p.div_nbr

left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 

)s
on s.div_nbr= din.div_nbr
and s.cust_nbr= din.cust_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr
	and c.cust_nbr = din.cust_nbr

where din.cust_nbr>0
and din.mostrecentweek=1
--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 

and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

group by p.div_nbr,p.prod_nbr, din.cust_nbr, din.elasticity2percent
) a
group by div_nbr,prod_nbr

;
-- endregion


/*statement 4: psi at division item level*/
-- region PSI div-item level
create temp table psi as 
select div_nbr,prod_nbr,round(sum(psi_weighted)/sum(qty),4) as weighted_psi, sum (kvi) as psi_cnt  from( 
select p.div_nbr,p.prod_nbr, din.cust_nbr, din.kvi, sum(s.unfrm_qty_ship) as qty, qty*din.kvi as psi_weighted
from dinesh_Customer_recs_Peihao_AllDivisions_20161119 din

left join prcmuser_usf_product p
on p.pim_usf_std_prod_cd= din.pim_usf_std_prod_cd
and din.div_nbr= p.div_nbr

left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 

)s
on s.div_nbr= din.div_nbr
and s.cust_nbr= din.cust_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr
	and c.cust_nbr = din.cust_nbr

where din.cust_nbr>0
and din.mostrecentweek=1
--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 

and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

group by p.div_nbr,p.prod_nbr, din.cust_nbr, din.elasticity2percent,din.kvi
) a
group by div_nbr,prod_nbr
;
-- endregion


/*statement 5: psi at division */
-- region PSI div level
create temp table psi_div as 
select div_nbr, sum (kvi) as psi_cnt_div  from( 
select p.div_nbr,p.prod_nbr, din.cust_nbr, din.kvi, sum(s.unfrm_qty_ship) as qty, qty*din.kvi as psi_weighted
from dinesh_Customer_recs_Peihao_AllDivisions_20161119 din

left join prcmuser_usf_product p
on p.pim_usf_std_prod_cd= din.pim_usf_std_prod_cd
and din.div_nbr= p.div_nbr

left join (select *
,	case when (cntrct_cpr_bsis is NULL and prc_src =1 and  ckbk_trgt_prc>0) or cntrct_cpr_bsis is not null  then 1
	else 0
	end as include_flag

from 
(
select *
from prcmuser_usf_sales_hist 
where (cntrct_cpr_bsis  not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO') 
or cntrct_cpr_bsis is null)
and prcs_dt between '2016-10-02' and '2016-12-31'

)b
where include_flag=1
and unfrm_qty_ship>0 

)s
on s.div_nbr= din.div_nbr
and s.cust_nbr= din.cust_nbr

left join prcmuser_usf_customer c /*to get cust_nm, menu_type.  Also removes cust<0 (which is is used for division-level and cohort-level recommendations)*/
	on s.div_nbr = c.div_nbr
	and s.cust_nbr = c.cust_nbr
	and c.cust_nbr = din.cust_nbr

where din.cust_nbr>0
and din.mostrecentweek=1
--and s.ntv_ord_typ not in ('CC') --chef store
and s.qty_ship>0 
and s.grs_sls_extnd>0 

and c.prc_bsis not in ('CCN','DDN','DWA','lpc','LIM','LPC','LPM','LPW','P07','PWW','LIC','PO')
and c.trd_cls=1
and c.inact_dt is null
and c.cust_nm not like '%ZZ%'
--and c.cust_natl_mngd_flg='L'

group by p.div_nbr,p.prod_nbr, din.cust_nbr, din.elasticity2percent,din.kvi
) a
group by div_nbr
;
-- endregion


/*Statement 6: grouping all the table in 1*/
-- region Grouping tables from statement 1 to 5
create temp table almost as
select 
a.div_prod_combo,
a.div_nbr,
a.prod_nbr,
a.div_nm,
a.pim_prod_desc_lng,
a.prc_uom,
a.net_wt,
a.sls_pack_size,
a.ctch_wt_ind,
a.prod_brnd,
a.pim_brnd_nm,
a.prod_lbl,
a.pim_brnd_typ_desc,
a.brk_ind,
a.cmdty_ind,
a.prod_shlf_life,
a.prod_stat_desc,
a.pim_usf_mfr_nm,
a.pim_cls_desc,
a.pim_ctgry_desc,
a.pim_grp_desc,
a.prod_rsrvbl_ind,
a.ttl_qty_cs,
a.cust_cnt,
a.cs_per_cust,
a.ave_cs_per_wk,
a.ttl_sales,
a.wkly_sales,

a.ttl_qty_cs_div
,a.cust_cnt_div 
,a.cs_per_cust_div
,a.ave_cs_per_wk_div
,a.ttl_sales_div
,a.wkly_sales_div 

,a.weighted_elasticity

,a.weighted_psi
, a.psi_cnt

,a.psi_cnt_div
,a.psi_share_of_item_in_div
, round(sum (a.lpc_201640),3) as lpc_201640
, round(sum (a.lpc_201641),3) as lpc_201641
, round(sum (a.lpc_201642),3) as lpc_201642
, round(sum (a.lpc_201643),3) as lpc_201643
, round(sum (a.lpc_201644),3) as lpc_201644
, round(sum (a.lpc_201645),3) as lpc_201645
, round(sum (a.lpc_201646),3) as lpc_201646
, round(sum (a.lpc_201647),3) as lpc_201647
, round(sum (a.lpc_201648),3) as lpc_201648
, round(sum (a.lpc_201649),3) as lpc_201649
, round(sum (a.lpc_201650),3) as lpc_201650
, round(sum (a.lpc_201651),3) as lpc_201651
, round(sum (a.lpc_201652),3) as lpc_201652

, round(sum (a.tmc_201640),3) as tmc_201640
, round(sum (a.tmc_201641),3) as tmc_201641
, round(sum (a.tmc_201642),3) as tmc_201642
, round(sum (a.tmc_201643),3) as tmc_201643
, round(sum (a.tmc_201644),3) as tmc_201644
, round(sum (a.tmc_201645),3) as tmc_201645
, round(sum (a.tmc_201646),3) as tmc_201646
, round(sum (a.tmc_201647),3) as tmc_201647
, round(sum (a.tmc_201648),3) as tmc_201648
, round(sum (a.tmc_201649),3) as tmc_201649
, round(sum (a.tmc_201650),3) as tmc_201650
, round(sum (a.tmc_201651),3) as tmc_201651
, round(sum (a.tmc_201652),3) as tmc_201652


from (
Select a_tabl.*
,b_tabl.ttl_qty_cs_div
,b_tabl.cust_cnt_div 
,b_tabl.cs_per_cust_div
,b_tabl.ave_cs_per_wk_div
,b_tabl.ttl_sales_div
,b_tabl.wkly_sales_div 

, ttl_qty_cs/ttl_qty_cs_div as item_div_share
, cast(cust_cnt as numeric (16,2))/cast(cust_cnt_div as numeric(16,2)) as cust_penetration 

,elast.weighted_elasticity

,psi.weighted_psi
,psi.psi_cnt

,psi_div.psi_cnt_div

, psi.psi_cnt/psi_div.psi_cnt_div as psi_share_of_item_in_div
/*28 to 40*/
, case when wkly_sls.fisc_yr_wk='201640' then round(wkly_sls.lpc,3) else 0 end as lpc_201640
, case when wkly_sls.fisc_yr_wk='201641' then round(wkly_sls.lpc,3) else 0 end as lpc_201641 
, case when wkly_sls.fisc_yr_wk='201642' then round(wkly_sls.lpc,3) else 0 end as lpc_201642
, case when wkly_sls.fisc_yr_wk='201643' then round(wkly_sls.lpc,3) else 0 end as lpc_201643
, case when wkly_sls.fisc_yr_wk='201644' then round(wkly_sls.lpc,3) else 0 end as lpc_201644
, case when wkly_sls.fisc_yr_wk='201645' then round(wkly_sls.lpc,3) else 0 end as lpc_201645
, case when wkly_sls.fisc_yr_wk='201646' then round(wkly_sls.lpc,3) else 0 end as lpc_201646	
, case when wkly_sls.fisc_yr_wk='201647' then round(wkly_sls.lpc,3) else 0 end as lpc_201647
, case when wkly_sls.fisc_yr_wk='201648' then round(wkly_sls.lpc,3) else 0 end as lpc_201648
, case when wkly_sls.fisc_yr_wk='201649' then round(wkly_sls.lpc,3) else 0 end as lpc_201649
, case when wkly_sls.fisc_yr_wk='201650' then round(wkly_sls.lpc,3) else 0 end as lpc_201650
, case when wkly_sls.fisc_yr_wk='201651' then round(wkly_sls.lpc,3) else 0 end as lpc_201651
, case when wkly_sls.fisc_yr_wk='201652' then round(wkly_sls.lpc,3) else 0 end as lpc_201652

, case when wkly_sls.fisc_yr_wk='201640' then round(wkly_sls.tmc,3) else 0 end as tmc_201640
, case when wkly_sls.fisc_yr_wk='201641' then round(wkly_sls.tmc,3) else 0 end as tmc_201641 
, case when wkly_sls.fisc_yr_wk='201642' then round(wkly_sls.tmc,3) else 0 end as tmc_201642
, case when wkly_sls.fisc_yr_wk='201643' then round(wkly_sls.tmc,3) else 0 end as tmc_201643
, case when wkly_sls.fisc_yr_wk='201644' then round(wkly_sls.tmc,3) else 0 end as tmc_201644
, case when wkly_sls.fisc_yr_wk='201645' then round(wkly_sls.tmc,3) else 0 end as tmc_201645
, case when wkly_sls.fisc_yr_wk='201646' then round(wkly_sls.tmc,3) else 0 end as tmc_201646	
, case when wkly_sls.fisc_yr_wk='201647' then round(wkly_sls.tmc,3) else 0 end as tmc_201647
, case when wkly_sls.fisc_yr_wk='201648' then round(wkly_sls.tmc,3) else 0 end as tmc_201648
, case when wkly_sls.fisc_yr_wk='201649' then round(wkly_sls.tmc,3) else 0 end as tmc_201649
, case when wkly_sls.fisc_yr_wk='201650' then round(wkly_sls.tmc,3) else 0 end as tmc_201650
, case when wkly_sls.fisc_yr_wk='201651' then round(wkly_sls.tmc,3) else 0 end as tmc_201651
, case when wkly_sls.fisc_yr_wk='201652' then round(wkly_sls.tmc,3) else 0 end as tmc_201652

from a_tabl

left join b_tabl
on a_tabl.div_nbr=b_tabl.div_nbr


left join elast
on elast.div_nbr=a_tabl.div_nbr
and a_tabl.prod_nbr = elast.prod_nbr

left join psi
on psi.div_nbr = a_tabl.div_nbr
and psi.prod_nbr = a_tabl.prod_nbr

left join psi_div
on psi_div.div_nbr= a_tabl.div_nbr

left join wkly_sls
on a_tabl.div_prod_combo= wkly_sls.div_prod_combo

group by 
a_tabl.div_prod_combo,
a_tabl.div_nbr,
a_tabl.prod_nbr,
a_tabl.div_nm,
a_tabl.pim_prod_desc_lng,
a_tabl.prc_uom,
a_tabl.net_wt,
a_tabl.sls_pack_size,
a_tabl.ctch_wt_ind,
a_tabl.prod_brnd,
a_tabl.pim_brnd_nm,
a_tabl.prod_lbl,
a_tabl.pim_brnd_typ_desc,
a_tabl.brk_ind,
a_tabl.cmdty_ind,
a_tabl.prod_shlf_life,
a_tabl.prod_stat_desc,
a_tabl.pim_usf_mfr_nm,
a_tabl.pim_cls_desc,
a_tabl.pim_ctgry_desc,
a_tabl.pim_grp_desc,
a_tabl.prod_rsrvbl_ind,
a_tabl.ttl_qty_cs,
a_tabl.cust_cnt,
a_tabl.cs_per_cust,
a_tabl.ave_cs_per_wk,
a_tabl.ttl_sales,
a_tabl.wkly_sales,

b_tabl.ttl_qty_cs_div
,b_tabl.cust_cnt_div 
,b_tabl.cs_per_cust_div
,b_tabl.ave_cs_per_wk_div
,b_tabl.ttl_sales_div
,b_tabl.wkly_sales_div 

,elast.weighted_elasticity

,psi.weighted_psi
, psi.psi_cnt

,psi_div.psi_cnt_div
,psi_share_of_item_in_div
,wkly_sls.fisc_yr_wk
, wkly_sls.lpc
, wkly_sls.tmc

) a

group by 
a.div_prod_combo,
a.div_nbr,
a.prod_nbr,
a.div_nm,
a.pim_prod_desc_lng,
a.prc_uom,
a.net_wt,
a.sls_pack_size,
a.ctch_wt_ind,
a.prod_brnd,
a.pim_brnd_nm,
a.prod_lbl,
a.pim_brnd_typ_desc,
a.brk_ind,
a.cmdty_ind,
a.prod_shlf_life,
a.prod_stat_desc,
a.pim_usf_mfr_nm,
a.pim_cls_desc,
a.pim_ctgry_desc,
a.pim_grp_desc,
a.prod_rsrvbl_ind,
a.ttl_qty_cs,
a.cust_cnt,
a.cs_per_cust,
a.ave_cs_per_wk,
a.ttl_sales,
a.wkly_sales,

a.ttl_qty_cs_div
,a.cust_cnt_div 
,a.cs_per_cust_div
,a.ave_cs_per_wk_div
,a.ttl_sales_div
,a.wkly_sales_div 

,a.weighted_elasticity

,a.weighted_psi
, a.psi_cnt

,a.psi_cnt_div
,a.psi_share_of_item_in_div
;
-- endregion


/*Statement 7: flagging and creating the relevent variables */

-- region Flagging and coding the variable
create temp table almost2 as 
select almost.*, 
/*lpc flags*/
case when lpc_201640=0 or almost.lpc_201641=0 then 0
	when round(lpc_201640,2)=round(lpc_201641,2) then 0
	else 1
	end as lpc_1,
	
case when lpc_201641=0 or almost.lpc_201642=0 then 0
	when round(lpc_201641,2)=round(lpc_201642,2) then 0
	else 1
	end as lpc_2,

case when lpc_201642=0 or almost.lpc_201643=0 then 0
	when round(lpc_201642,2)=round(lpc_201643,2) then 0
	else 1
	end as lpc_3,	
	
case when lpc_201643=0 or almost.lpc_201644=0 then 0
	when round(lpc_201643,2)=round(lpc_201644,2) then 0
	else 1
	end as lpc_4,	

case when lpc_201644=0 or almost.lpc_201645=0 then 0
	when round(lpc_201644,2)=round(lpc_201645,2) then 0
	else 1
	end as lpc_5,	

case when lpc_201645=0 or almost.lpc_201646=0 then 0
	when round(lpc_201645,2)=round(lpc_201646,2) then 0
	else 1
	end as lpc_6,	
	
case when lpc_201646=0 or almost.lpc_201647=0 then 0
	when round(lpc_201646,2)=round(lpc_201647,2) then 0
	else 1
	end as lpc_7,	

case when lpc_201647=0 or almost.lpc_201648=0 then 0
	when round(lpc_201647,2)=round(lpc_201648,2) then 0
	else 1
	end as lpc_8,

case when lpc_201648=0 or almost.lpc_201649=0 then 0
	when round(lpc_201648,2)=round(lpc_201649,2) then 0
	else 1
	end as lpc_9,	

case when lpc_201649=0 or almost.lpc_201650=0 then 0
	when round(lpc_201649,2)=round(lpc_201650,2) then 0
	else 1
	end as lpc_10,
	
case when lpc_201650=0 or almost.lpc_201651=0 then 0
	when round(lpc_201650,2)=round(lpc_201651,2) then 0
	else 1
	end as lpc_11,	

case when lpc_201651=0 or almost.lpc_201652=0 then 0
	when round(lpc_201651,2)=round(lpc_201652,2) then 0
	else 1
	end as lpc_12,	

-------------------
-------------------
-------------------
--lpc change %

case when lpc_201640=0 or almost.lpc_201641=0 then NULL
	when round(lpc_201640,2)=round(lpc_201641,2) then 0
	else abs(round(lpc_201641,2)/(0.00000001+round(lpc_201640,2))-1)
	end as lpc_1_perc,
	
case when lpc_201641=0 or almost.lpc_201642=0 then NULL
	when round(lpc_201641,2)=round(lpc_201642,2) then 0
	else abs(round(lpc_201642,2)/(0.00000001+round(lpc_201641,2))-1)
	end as lpc_2_perc,

case when lpc_201642=0 or almost.lpc_201643=0 then NULL
	when round(lpc_201642,2)=round(lpc_201643,2) then 0
	else abs(round(lpc_201643,2)/(0.00000001+round(lpc_201642,2))-1)
	end as lpc_3_perc,	
	
case when lpc_201643=0 or almost.lpc_201644=0 then NULL
	when round(lpc_201643,2)=round(lpc_201644,2) then 0
	else abs(round(lpc_201644,2)/(0.00000001+round(lpc_201643,2))-1)
	end as lpc_4_perc,	

case when lpc_201644=0 or almost.lpc_201645=0 then NULL
	when round(lpc_201644,2)=round(lpc_201645,2) then 0
	else abs(round(lpc_201645,2)/(0.00000001+round(lpc_201644,2))-1)
	end as lpc_5_perc,	

case when lpc_201645=0 or almost.lpc_201646=0 then NULL
	when round(lpc_201645,2)=round(lpc_201646,2) then 0
	else abs(round(lpc_201646,2)/(0.00000001+round(lpc_201645,2))-1)
	end as lpc_6_perc,	
	
case when lpc_201646=0 or almost.lpc_201647=0 then NULL
	when round(lpc_201646,2)=round(lpc_201647,2) then 0
	else abs(round(lpc_201647,2)/(0.00000001+round(lpc_201646,2))-1)
	end as lpc_7_perc,	

case when lpc_201647=0 or almost.lpc_201648=0 then NULL
	when round(lpc_201647,2)=round(lpc_201648,2) then 0
	else abs(round(lpc_201648,2)/(0.00000001+round(lpc_201647,2))-1)
	end as lpc_8_perc,

case when lpc_201648=0 or almost.lpc_201649=0 then NULL
	when round(lpc_201648,2)=round(lpc_201649,2) then 0
	else abs(round(lpc_201649,2)/(0.00000001+round(lpc_201648,2))-1)
	end as lpc_9_perc,	

case when lpc_201649=0 or almost.lpc_201650=0 then NULL
	when round(lpc_201649,2)=round(lpc_201650,2) then 0
	else abs(round(lpc_201650,2)/(0.00000001+round(lpc_201649,2))-1)
	end as lpc_10_perc,
	
case when lpc_201650=0 or almost.lpc_201651=0 then NULL
	when round(lpc_201650,2)=round(lpc_201651,2) then 0
	else abs(round(lpc_201651,2)/(0.00000001+round(lpc_201650,2))-1)
	end as lpc_11_perc,	

case when lpc_201651=0 or almost.lpc_201652=0 then NULL
	when round(lpc_201651,2)=round(lpc_201652,2) then 0
	else abs(round(lpc_201652,2)/(0.00000001+round(lpc_201651,2))-1)
	end as lpc_12_perc,



	
/*tmc flags*/
case when tmc_201640=0 or almost.tmc_201641=0 then 0
	when round(tmc_201640,2)=round(tmc_201641,2) then 0
	else 1
	end as tmc_1,
	
case when tmc_201641=0 or almost.tmc_201642=0 then 0
	when round(tmc_201641,2)=round(tmc_201642,2) then 0
	else 1
	end as tmc_2,

case when tmc_201642=0 or almost.tmc_201643=0 then 0
	when round(tmc_201642,2)=round(tmc_201643,2) then 0
	else 1
	end as tmc_3,	
	
case when tmc_201643=0 or almost.tmc_201644=0 then 0
	when round(tmc_201643,2)=round(tmc_201644,2) then 0
	else 1
	end as tmc_4,	

case when tmc_201644=0 or almost.tmc_201645=0 then 0
	when round(tmc_201644,2)=round(tmc_201645,2) then 0
	else 1
	end as tmc_5,	

case when tmc_201645=0 or almost.tmc_201646=0 then 0
	when round(tmc_201645,2)=round(tmc_201646,2) then 0
	else 1
	end as tmc_6,	
	
case when tmc_201646=0 or almost.tmc_201647=0 then 0
	when round(tmc_201646,2)=round(tmc_201647,2) then 0
	else 1
	end as tmc_7,	

case when tmc_201647=0 or almost.tmc_201648=0 then 0
	when round(tmc_201647,2)=round(tmc_201648,2) then 0
	else 1
	end as tmc_8,

case when tmc_201648=0 or almost.tmc_201649=0 then 0
	when round(tmc_201648,2)=round(tmc_201649,2) then 0
	else 1
	end as tmc_9,	

case when tmc_201649=0 or almost.tmc_201650=0 then 0
	when round(tmc_201649,2)=round(tmc_201650,2) then 0
	else 1
	end as tmc_10,
	
case when tmc_201650=0 or almost.tmc_201651=0 then 0
	when round(tmc_201650,2)=round(tmc_201651,2) then 0
	else 1
	end as tmc_11,	

case when tmc_201651=0 or almost.tmc_201652=0 then 0
	when round(tmc_201651,2)=round(tmc_201652,2) then 0
	else 1
	end as tmc_12	
	
	
, (lpc_1+lpc_2+lpc_3+lpc_4+lpc_5+lpc_6+lpc_7+lpc_8+lpc_9+lpc_10+lpc_11+lpc_12) as lpc_chng_frequency
, (lpc_1+tmc_2+tmc_3+tmc_4+tmc_5+tmc_6+tmc_7+tmc_8+tmc_9+tmc_10+tmc_11+tmc_12) as tmc_chng_frequency
, round((nvl(lpc_1_perc,0)+ nvl(lpc_2_perc,0)+nvl(lpc_3_perc,0)+nvl(lpc_4_perc,0)+nvl(lpc_5_perc,0)+nvl(lpc_6_perc,0)+nvl(lpc_7_perc,0)+nvl(lpc_8_perc,0)+nvl(lpc_9_perc,0))+nvl(lpc_10_perc,0)+nvl(lpc_11_perc,0)+nvl(lpc_12_perc,0)/((count(NULLIF(lpc_1_perc,0))+ count(NULLIF(lpc_2_perc,0))+count(NULLIF(lpc_3_perc,0))+count(NULLIF(lpc_4_perc,0))+count(NULLIF(lpc_5_perc,0))+count(NULLIF(lpc_6_perc,0))+count(NULLIF(lpc_7_perc,0))+count(NULLIF(lpc_8_perc,0))+count(NULLIF(lpc_9_perc,0))+count(NULLIF(lpc_10_perc,0))+count(NULLIF(lpc_11_perc,0))+count(NULLIF(lpc_12_perc,0)))+0.00000000001),4) as average_change_lpc
, case when average_change_lpc >= 0.03 then 1 else 0 end as perc_chng_lpc_3_plus
, (case when average_change_lpc >= 0.01 then 1 else 0 end) as perc_chng_1_plus
, (case when average_change_lpc>0 then 1 else 0 end) as perc_chng_0_plus


from almost 

group by 
div_prod_combo,
div_nbr,
prod_nbr,
div_nm,
pim_prod_desc_lng,
prc_uom,
net_wt,
sls_pack_size,
ctch_wt_ind,
prod_brnd,
pim_brnd_nm,
prod_lbl,
pim_brnd_typ_desc,
brk_ind,
cmdty_ind,
prod_shlf_life,
prod_stat_desc,
pim_usf_mfr_nm,
pim_cls_desc,
pim_ctgry_desc,
pim_grp_desc,
prod_rsrvbl_ind,
ttl_qty_cs,
cust_cnt,
cs_per_cust,
ave_cs_per_wk,
ttl_sales,
wkly_sales,
ttl_qty_cs_div,
cust_cnt_div,
cs_per_cust_div,
ave_cs_per_wk_div,
ttl_sales_div,
wkly_sales_div,
weighted_elasticity,
weighted_psi,
psi_cnt,
psi_cnt_div,
psi_share_of_item_in_div,
lpc_201640,
lpc_201641,
lpc_201642,
lpc_201643,
lpc_201644,
lpc_201645,
lpc_201646,
lpc_201647,
lpc_201648,
lpc_201649,
lpc_201650,
lpc_201651,
lpc_201652,
tmc_201640,
tmc_201641,
tmc_201642,
tmc_201643,
tmc_201644,
tmc_201645,
tmc_201646,
tmc_201647,
tmc_201648,
tmc_201649,
tmc_201650,
tmc_201651,
tmc_201652,
lpc_1,
lpc_2,
lpc_3,
lpc_4,
lpc_5,
lpc_6,
lpc_7,
lpc_8,
lpc_9,
lpc_10,
lpc_11,
lpc_12,
lpc_1_perc,
lpc_2_perc,
lpc_3_perc,
lpc_4_perc,
lpc_5_perc,
lpc_6_perc,
lpc_7_perc,
lpc_8_perc,
lpc_9_perc,
lpc_10_perc,
lpc_11_perc,
lpc_12_perc,
tmc_1,
tmc_2,
tmc_3,
tmc_4,
tmc_5,
tmc_6,
tmc_7,
tmc_8,
tmc_9,
tmc_10,
tmc_11,
tmc_12,
lpc_chng_frequency,
tmc_chng_frequency
	
; 
-- endregion


/*Statement 8: Creating additional relevent variables */
-- region Creating other variables
create temp table akh as 
select 

almost2.div_prod_combo,
almost2.div_nbr,
almost2.prod_nbr,
almost2.div_nm,
almost2.pim_prod_desc_lng,
almost2.prc_uom,
almost2.net_wt,
almost2.sls_pack_size,
almost2.ctch_wt_ind,
almost2.prod_brnd,
almost2.pim_brnd_nm,
almost2.prod_lbl,
almost2.pim_brnd_typ_desc,
almost2.brk_ind,
almost2.cmdty_ind,
almost2.prod_shlf_life,
almost2.prod_stat_desc,
almost2.pim_usf_mfr_nm,
almost2.pim_cls_desc,
almost2.pim_ctgry_desc,
almost2.pim_grp_desc,
almost2.prod_rsrvbl_ind,

almost2.ttl_qty_cs,
sum(s.unfrm_qty_ship) as qty_all_cust,

almost2.cust_cnt,
almost2.ttl_sales,

almost2.ttl_qty_cs/almost2.ttl_qty_cs_div as qty_penetration,
cast (almost2.cust_cnt as numeric(16,0))/cast(almost2.cust_cnt_div as numeric(16,0)) as cust_penetration,
almost2.ttl_sales/almost2.ttl_sales_div as sales_penetration,

--almost2.ttl_qty_cs_div,
--almost2.cust_cnt_div,
--almost2.ttl_sales_div,
almost2.weighted_elasticity,
almost2.psi_cnt,
almost2.psi_share_of_item_in_div,
almost2.lpc_chng_frequency,
almost2.tmc_chng_frequency,

almost2.perc_chng_lpc_3_plus,
almost2.perc_chng_1_plus,
almost2.perc_chng_0_plus

--,case when almost2.ttl_qty_cs>153 then 1
--	else 0 end as flag_qty_com


from almost2 

left join prcmuser_usf_sales_hist s
on almost2.div_nbr= s.div_nbr
and almost2.prod_nbr = s.prod_nbr



where s.prcs_dt between '2016-10-02' and '2016-12-31'

group by 
almost2.div_prod_combo,
almost2.div_nbr,
almost2.prod_nbr,
almost2.div_nm,
almost2.pim_prod_desc_lng,
almost2.prc_uom,
almost2.net_wt,
almost2.sls_pack_size,
almost2.ctch_wt_ind,
almost2.prod_brnd,
almost2.pim_brnd_nm,
almost2.prod_lbl,
almost2.pim_brnd_typ_desc,
almost2.brk_ind,
almost2.cmdty_ind,
almost2.prod_shlf_life,
almost2.prod_stat_desc,
almost2.pim_usf_mfr_nm,
almost2.pim_cls_desc,
almost2.pim_ctgry_desc,
almost2.pim_grp_desc,
almost2.prod_rsrvbl_ind,

almost2.ttl_qty_cs,
--sum(s.unfrm_qty_ship) as qty_all_cust,

almost2.cust_cnt,
almost2.ttl_sales,

qty_penetration,
cust_penetration,
sales_penetration,

almost2.weighted_elasticity,
almost2.psi_cnt,
almost2.psi_share_of_item_in_div,
almost2.lpc_chng_frequency,
almost2.tmc_chng_frequency,
almost2.perc_chng_lpc_3_plus,
almost2.perc_chng_1_plus,
almost2.perc_chng_0_plus
;
-- endregion


------The below should be grayed out if the full script is being excecuted
------below used for threshold calculation
/*Statement 8B: Getting all variables in statement 8 but filtering rows for exclusions. Exclusions not to be used for threshhold determination*/

-- region Exclusions- Filtered categories
--select * 
--	from akh
--	where akh.pim_cls_desc not in ('BEVERAGE','FRUITS & VEGETABLES, CANNED & DRIED','CHEMICALS & CLEANING AGENTS')--no commodity in these pim classes
--	and akh.div_nm not in ('CHARLOTTE')
--	and akh.pim_grp_desc not in ('STRAWBERRIES, VALUE ADDED, FRESH',
--									'CITRUS, VALUE ADDED, FRESH, LIGHTLY PRESERVED',
--									'GRAPEFRUIT, FRESH, VALUE ADDED',
--									'LEMON, FRESH, VALUE ADDED',
--									'ORANGES, FRESH, VALUE ADDED',
--									'FLOWERS, PLANTS, & TREES',
--									'GARLIC, VALUE ADDED, FRESH',
--									'MICRO GREENS, FRESH',
--									'SPROUTS, FRESH',
--									'CILANTRO, FRESH, VALUE ADDED',
--									'HERBS, OTHER, FRESH',
--									'OTHER HERBS & SPROUTS, VALUE ADDED, FRESH',
--									'PARSLEY, FRESH, VALUE ADDED',
--									'ARUGULA, FRESH',
--									'GREENS, OTHER, FRESH',
--									'KALE, FRESH',
--									'LETTUCE, ICEBERG, FRESH, VALUE ADDED',
--									'LETTUCE, LEAF GREEN, FRESH, VALUE ADDED',
--									'LETTUCE, LEAF RED, FRESH, VALUE ADDED',
--									'LETTUCE, ROMAINE, FRESH, VALUE ADDED',
--									'SPINACH, FRESH',
--									'SPINACH, FRESH, VALUE ADDED',
--									'MUSHROOMS, BROWNS, FRESH',
--									'MUSHROOMS, EXOTICS, FRESH',
--									'MUSHROOMS, WHITE, FRESH',
--									'MUSHROOMS, BROWNS, FRESH, VALUE ADDED',
--									'MUSHROOMS, EXOTICS, FRESH, VALUE ADDED',
--									'MUSHROOMS, WHITE, FRESH, VALUE ADDED',
--									'VEGETABLES BLENDS, VALUE ADDED, FRESH',
--									'BEANS, GREEN, FRESH, VALUE ADDED',
--									'PEAS, VALUE ADDED, FRESH',
--									'BEETS, FRESH',
--									'RADISHES, FRESH',
--									'ROOT VEGETABLES, OTHER, FRESH',
--									'RUTABAGAS, FRESH',
--									'TURNIP GREENS, FRESH',
--									'BEETS, FRESH, VALUE ADDED',
--									'CARROTS, FRESH, VALUE ADDED',
--									'RADISHES, FRESH, VALUE ADDED',
--									'ROOT VEGETABLES, OTHER, VALUE ADDED, FRESH',
--									'GARDEN SALAD KIT, FRESH',
--									'GARDEN SALAD MIXES, FRESH',
--									'ARTICHOKES, FRESH',
--									'ASPARAGUS, VALUE ADDED, FRESH',
--									'BRUSSEL SPROUTS, FRESH',
--									'CORN, FRESH',
--									'ARTICHOKES, FRESH, VALUE ADDED',
--									'BROCCOLI, FRESH, VALUE ADD',
--									'BRUSSEL SPROUTS, FRESH, VALUE ADDED',
--									'CABBAGE, FRESH, VALUE ADDED',
--									'CAULIFLOWER, FRESH, VALUE ADDED',
--									'CELERY, FRESH, VALUE ADDED',
--									'COLESLAW PRODUCT BLENDS, FRESH',
--									'CORN, FRESH, VALUE ADDED',
--									'VEGETABLES, OTHER, FRESH, VALUE ADDED',
--									'LETTUCE, ENDIVE, FRESH',
--									'LETTUCE, ESCAROLE, FRESH',
--									'BANANAS, FRESH',
--									'BANANAS, FRESH, VALUE ADDED',
--									'LIMES, FRESH, VALUE ADDED',
--									'CUT FRUIT, MIXED / MULTI COMPONENT',
--									'CUT FRUIT, MIXED / MULTI COMPONENT, LIGHTLY PRESERVED',
--									'FRUITS, MIXED, FRUIT BASKETS, FRESH',
--									'MELON, CUT FRUIT, MIXED / MULTI COMPONENT',
--									'GRAPES, GREEN, VALUE ADDED, FRESH',
--									'GRAPES, OTHER, VALUE ADDED, FRESH',
--									'GRAPES, RED, VALUE ADDED, FRESH',
--									'GRAPES, VALUE ADDED, FRESH, LIGHTLY PRESERVED',
--									'CANTALOUPE, FRESH, VALUE ADDED',
--									'HONEYDEW, FRESH, VALUE ADDED',
--									'MELONS, VALUE ADDED, FRESH, LIGHTLY PRESERVED',
--									'WATERMELON, FRESH, VALUE ADDED',
--									'NECTARINES, FRESH',
--									'PEACHES, FRESH',
--									'PLUMS, FRESH',
--									'STONE FRUIT, OTHER, FRESH',
--									'APPLES, RED & BLENDS, VALUE ADDED, FRESH',
--									'PEARS, FRESH, VALUE ADD',
--									'CARAMBOLA/STAR FRUIT, FRESH',
--									'COCONUTS, FRESH',
--									'FRUIT, OTHER FRESH',
--									'KIWIFRUIT, FRESH',
--									'MANGOES, FRESH',
--									'PAPAYAS, FRESH',
--									'PLANTAINS, FRESH',
--									'TROPICAL FRUIT, OTHER, FRESH',
--									'MANGOES, FRESH, VALUE ADDED',
--									'PINEAPPLE, FRESH, VALUE ADDED',
--									'TROPICAL, CUT FRUIT, MIXED / MULTI COMPONENT',
--									'CUCUMBERS, FRESH, VALUE ADDED',
--									'EGGPLANT, FRESH',
--									'SQUASH, FRESH, VALUE ADDED',
--									'ZUCCHINI, FRESH, VALUE ADDED',
--									'LEEKS, FRESH',
--									'LEEKS, FRESH, VALUE ADDED',
--									'ONIONS, GREEN, FRESH',
--									'ONIONS, GREEN, FRESH, VALUE ADDED',
--									'ONIONS, OTHER, VALUE ADDED, FRESH',
--									'ONIONS, RED, FRESH, VALUE ADDED',
--									'ONIONS, VALUE ADDED, FRESH, LIGHTLY PRESERVED',
--									'ONIONS, WHITE, FRESH, VALUE ADDED',
--									'ONIONS, YELLOW, FRESH, VALUE ADDED',
--									'PEPPERS, CHILI, OTHER, VALUE ADDED, FRESH',
--									'PEPPERS, GREEN BELL, FRESH, VALUE ADDED',
--									'PEPPERS, JALAPENO, VALUE ADDED, FRESH',
--									'PEPPERS, OTHER, FRESH, VALUE ADDED',
--									'PEPPERS, RED BELL, FRESH, VALUE ADDED',
--									'PEPPERS, YELLOW BELL, FRESH, VALUE ADDED',
--									'POTATOES, RED, FRESH, VALUE ADDED',
--									'POTATOES, SPECIALTY, OTHER, FRESH, VALUE ADDED',
--									'POTATOES, SWEET & YAMS FRESH, VALUE ADDED',
--									'POTATOES, WHITE, FRESH, VALUE ADDED',
--									'POTATOES, YELLOW, FRESH, VALUE ADDED',
--									'PICO DE GALLO',
--									'TOMATOES, FRESH, VALUE ADDED',
--									'PUMPKINS, FRESH',
--								/*produce Exclusions- 116 PIM Groups*/
--									'CHICKEN, TENDERLOINS, TENDERS & STRIP MEAT, RAW, BREADED, FROZEN',
--									'TURKEY BREAST, COOKED, UNSLICED, REFRIGERATED',
--									'CHICKEN, TENDERLOINS, TENDERS & STRIP MEAT, COOKED, BREADED, FROZEN',
--									'CHICKEN, TENDERLOINS, TENDERS & STRIP MEAT, COOKED, UNBREADED',
--									'CHICKEN, BREAST & PATTY, BONELESS, BREADED, COOKED, FROZEN',
--									'CHICKEN, CUTS, COOKED, BREADED & UNBREADED (QTRS, HALVES, PIECES, & WHOLE BIRDS)',
--									'TURKEY BREAST, COOKED, SLICED, REFRIGERATED',
--									'TURKEY, PATTIES, GROUND, RAW, FROZEN',
--									'CHICKEN, PHILLY STYLE, FROZEN',
--									'TURKEY, PROCESSED, OTHER, FROZEN',
--									'TURKEY BACON, COOKED, REFRIGERATED',
--									'CHICKEN, TENDERLOINS, TENDERS & STRIP MEAT, RAW, UNBREADED, FROZEN',
--									'TURKEY BACON, RAW, REFRIGERATED',
--									'TURKEY WINGS',
--									'TURKEY BREAST, COOKED, SLICED, FROZEN',
--									'CHICKEN, PARTS, BREADED, RAW',
--									'TURKEY THIGHS',
--									'TURKEY, PROCESSED, OTHER, REFRIGERATED',
--								/*Poultry PIM Group exclusions - 18 PIM Groups*/	
--									'PORK, BACON, SLICED, PRE-COOKED, REFRIGERATED',
--									'BACON BITS & PIECES, COOKED, REFRIGERATED',
--									'PORK, CHOPS, BONE IN, RAW, FROZEN',
--									'PORK, BBQ, PULLED, CHOPPED, SHREDDED, COOKED, FROZEN',
--									'PORK, PRECOOKED, OTHER, FROZEN',
--									'PORK, PRECOOKED, OTHER, REFRIGERATED',
--									'CANADIAN BACON, BULK OR SLICES, REFRIGERATED',
--									'PORK, PATTIES, BREADED & UNBREADED, FROZEN',
--									'PORK, HAM, PROSCIUTTO, REFRIGERATED',
--									'PORK, CHOPS, FILLETS, RAW, FROZEN',
--									'HAM, SPECIALTY, SLICED, DICED, STRIPS, REFRIGERATED',
--									'BACON BITS & PIECES, RAW, FROZEN',
--									'PORK, DICED, STRIPS & CHUNKS, UNBREADED, RAW, FROZEN',
--									'PORK, BACON, PANCETTA, REFRIGERATED',
--									'FAT BACK, HOCKS & SHANKS, FROZEN',
--									'PORK, STEAK/CUTLETS/MEDALLIONS, UNBREADED, RAW, FROZEN',
--									'PORK, HAM, SPECIALTY, OTHER, REFRIGERATED',
--									'BACON BITS & PIECES, RAW, REFRIGERATED',
--									'PORK, OTHER PARTS, UNBREADED, RAW, REFRIGERATED',
--									'PORK, CHOPS, BONE IN, RAW, REFRIGERATED',
--									'PORK, BBQ, PULLED, CHOPPED, SHREDDED, COOKED, REFRIGERATED',
--									'PORK, HAM, SPECIALTY, OTHER, FROZEN',
--									'PORK, BACON, PANCETTA, FROZEN',
--								/*Pork PIM Group exclusions - 23 PIM Groups */	
--								    'CATFISH, BREADED, FROZEN, DOMESTIC',
--									'CLAMS, BREADED OR BATTERED',
--									'COD, BREADED OR BATTERED',
--									'CRABMEAT, BREADED/BATTERED (NOT CRAB CAKES)',
--									'FISH, OTHER, BREADED FROZEN',
--									'HADDOCK, BREADED OR BATTERED',
--									'HALIBUT, BREADED OR BATTERED',
--									'OYSTERS, BREADED OR BATTERED',
--									'PANGASIUS, BREADED, FROZEN',
--									'PERCH, OCEAN, BREADED',
--									'PIKE, BREADED',
--									'POLLOCK, BREADED OR BATTERED',
--									'SALMON, BREADED/BATTERED OR SEASONED, FROZEN, FARMED',
--									'SALMON, BREADED/BATTERED OR SEASONED, FROZEN, WILD',
--									'SCALLOP, BREADED OR BATTERED',
--									'SEAFOOD, BREADED, OTHER, FROZEN',
--									'SHRIMP, BREADED, FROZEN',
--									'SQUID & CALAMARI, BREADED',
--									'TILAPIA, BREADED OR BATTERED, FROZEN',
--									'TROUT, BREADED FROZEN',
--									'WHITING, BREADED OR BATTERED',
--									'FLOUNDER/SOLE, VALUE ADDED, FROZEN',
--									'HERRING & ANCHOVIES, VALUE ADDED, REFRIGERATED'
--								/*Seafood PIM Group exclusions - 23 PIM Groups */
--
--								)
--;
-- endregion


/*statement 9: Division level threshold and rules were applied here to get the flag*/
/*need to cross with the most recent threshhold table*/
-- region Thresholds applied and binary codes generated
select akh.*,kvi_threshold_v3.*, p.prod_shlf_life

, case when p.prod_shlf_life<15 then 1 else 0 end as less_than_15days_shelflife
, case when p.prod_shlf_life<22 then 1 else 0 end as less_than_22days_shelflife
, case when p.prod_shlf_life<61 then 1 else 0 end as less_than_61days_shelflife
, case when akh.ttl_qty_cs < kvi_threshold_v3.qty_threshold then 0 else 1 end as qty_kvi
, case when akh.cust_cnt < kvi_threshold_v3.cust_cnt_threshold then 0 else 1 end as cust_cnt_kvi
, case when akh.ttl_sales < kvi_threshold_v3.ttl_sales_threshold then 0 else 1 end as sales_kvi
, case when akh.qty_penetration < kvi_threshold_v3.qty_penetration_threshold then 0 else 1 end as qty_pen_kvi
, case when akh.cust_penetration < kvi_threshold_v3.cust_penetration_threshold then 0 else 1 end as cust_pen_kvi
, case when akh.weighted_elasticity < kvi_threshold_v3.weighted_elasticity_threshold then 1 else 0 end as elasticity_kvi
, case when akh.psi_cnt < kvi_threshold_v3.psi_cnt_threshold then 0 else 1 end as psi_cnt_kvi
, case when akh.psi_share_of_item_in_div < kvi_threshold_v3.psi_share_of_item_in_div_threshold then 0 else 1 end as psi_share_kvi
, case when akh.lpc_chng_frequency < kvi_threshold_v3.lpc_chng_frequency_threshold then 0 else 1 end as lpc_chng_kvi

, lpc_chng_kvi*perc_chng_lpc_3_plus as more_than3perc_chng
, lpc_chng_kvi*perc_chng_1_plus as more_than1perc_chng
, lpc_chng_kvi*perc_chng_0_plus as more_than0perc_chng

--,(0.1*less_than_15days_shelflife+0.1*less_than_22days_shelflife+0.1*less_than_61days_shelflife+0.05*qty_kvi+0.15*sales_kvi+0.05*qty_pen_kvi+0.05*cust_cnt_kvi+0.1*cust_pen_kvi+0.05*elasticity_kvi+0.05*psi_cnt_kvi+0.05*psi_share_kvi+0.1*more_than3perc_chng+0.1*more_than1perc_chng+0.1*more_than0perc_chng)/1.15 as score

from akh
left join kvi_threshold_v3
on kvi_threshold_v3.div_nm= akh.div_nm


left join prcmuser_usf_product p
on akh.prod_nbr= p.prod_nbr
and akh.div_nbr= p.div_nbr

--32646
;
-- endregion
