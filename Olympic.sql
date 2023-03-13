select * from dbo.athleta_events$
select * from dbo.noc_regions$

--1. Top 3 countries with the most gold medals
select top 3 n.region, count(a.Medal) as number_of_Gold_medal from dbo.athleta_events$ a join dbo.noc_regions$ n
on a.noc=n.noc where a.Medal='Gold'
group by n.region
order by count(a.Medal) desc


--2. For Each sport presents the outstanding country and the amount of victories
with a as(
select a.sport as Sport,n.region as Region, rank () over (partition by a.sport order by count(a.Medal) desc) r, count(a.Medal)
as Number_Of_Victories
from dbo.athleta_events$ a join dbo.noc_regions$ n
on a.noc=n.noc where a.Medal='Gold'
group by a.sport,n.region
) 
select sport,region,Number_Of_Victories from a where a.r=1
order by Number_Of_Victories desc

--3 The kinds of medals each region has
select distinct n.region, 
sum(case when a.Medal='Gold' then 1 else 0 end) as number_Gold_Medals,
sum(case when a.Medal='Silver' then 1 else 0 end) as number_Silver_Medals,
sum(case when a.Medal='Bronze' then 1 else 0 end) as number_Bronze_Medals
from dbo.athleta_events$ a join dbo.noc_regions$ n
on a.noc=n.noc
group by n.region
order by 2 desc

--4. Percentage of participation women and men
with g as(
select sum(case when a.Sex='F' then 1 else 0 end) as female,
sum(case when a.Sex='M' then 1 else 0 end) as male
from dbo.athleta_events$ a)
select cast(round(cast(female as float)/cast(count(a.ID)as float)*100,2) as varchar)+'%' as female,
cast(round(cast(male as float)/cast(count(a.ID)as float)*100,2) as varchar)+'%' as  male
from g, dbo.athleta_events$ a
group by female,male


--5. Distribution of the percentage of women and men each year
select a.year, 
cast(round(cast(sum(case when a.Sex='F' then 1 else 0 end)as float)/cast(count(a.id) as float)*100,2)as varchar)+'%' as female,
cast(round(cast(sum(case when a.Sex='M' then 1 else 0 end)as float)/cast(count(a.id) as float)*100,2)as varchar)+'%' as male
from dbo.athleta_events$ a
group by a.year
order by 1


--6. The number of times champions lost before winning a medal for the first time
with loss as(
select distinct a.Year as year, a.id as id ,a.name as name, count(a.id) as number_of_loss from dbo.athleta_events$ a where a.Medal='NA'
group by a.id,a.name, a.Year)
,win as(
select distinct a.Year as year, a.id as id ,a.name as name from dbo.athleta_events$ a where a.Medal<>'NA'
group by a.id,a.name, a.Year)
 
select l.name,sum(case when l.year<w.year then 1 else 0 end) as Number_of_attempts_before_receiving_a_medal
from loss l join win w on l.id=w.id 
group by l.name
order by 2 desc


