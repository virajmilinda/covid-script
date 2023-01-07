select *
from coviddeaths2;


select *
from coviddeaths2

where continent is not null
order by 1 ,2;

-- liklyhood of dying from covid in sri lanka

select location, date, total_cases,  total_deaths, population, (total_deaths/total_cases)*100 as death_rate
from coviddeaths2
where continent is not null and
location like '%lanka%'
order by 1 ,2;

-- what percentage of population catch covid

select location, date, total_cases,  total_deaths, population, (total_cases/population)*100 as infection_rate
from coviddeaths2
where continent is not null and
location like '%lanka%'
order by 6 desc ,2;


-- country with hieghst infection rate

select location,   population,max(total_cases) as highest_cases, 
max((total_cases/population))*100 as max_infection_rate
from coviddeaths2
-- where location like '%lanka%'
where continent is not null
group by location, population
order by 4 desc, 1 ;

-- country with highest deaths

select location,  sum(cast(total_deaths as signed)) as death_count
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
group by location
order by 2 desc ,1  ;

-- continents with highest deaths

select continent,  sum(cast(total_deaths as signed)) as death_count
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
group by continent
order by 2 desc ,1  ;

-- continents with highest death rates

select continent,  sum(cast(new_deaths as signed)) as death_count
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
group by continent
order by 2 desc ,1  ;

-- country with highest death rate

select location,  population,max(cast(total_deaths as signed)) as max_death_count, 
(max(cast(total_deaths as signed)/cast(population as signed)))*100 as deaths_rate
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
group by location,  population
order by 4 desc ,1  ;



-- Global Numbers

-- total deaths, cases and deaths to cases ratio

select sum(cast(new_cases as signed)) as world_case_count, sum(cast(new_deaths as signed)) as world_death_count,
(sum(cast(new_deaths as signed))/sum(cast(new_cases as signed)))*100 as dtoiratio
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
-- group by continent
order by 1 desc  ;



-- global cases/deaths by date

select date,sum(cast(new_cases as signed)) as case_count,  sum(cast(new_deaths as signed)) as death_count,    
sum(cast(new_deaths as signed))/sum(cast(new_cases as signed))*100 as death_rate
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
group by date
order by 1  ,2  ;


-- Global Total cases/deaths 

select sum(cast(new_cases as signed)) as case_count,  sum(cast(new_deaths as signed)) as death_count,    
sum(cast(new_deaths as signed))/sum(cast(new_cases as signed))*100 as death_rate
from coviddeaths2
-- where location like '%''%'
where continent is not null and continent <> '' and population <> ''
-- group by date
order by 1  ,2  ;




select  coviddeaths2.date as date,covidvaccinations2.date as date2, coviddeaths2.location as country, covidvaccinations2.new_vaccinations as vaccinations_count
from coviddeaths2
left join covidvaccinations2 ON coviddeaths2.date=covidvaccinations2.date
and coviddeaths2.location=covidvaccinations2.location
where coviddeaths2.continent is not null and coviddeaths2.continent <> '' and coviddeaths2.population <> ''
-- group by location,  population
order by 3  ,2  ;

-- Vaccinations

-- All
select *
from covidvaccinations2;

-- Vaccinations by country

select location as Country, sum(new_vaccinations) as Vaccinations
from covidvaccinations2
where continent is not null and continent <> ''

group by location
order by 2 desc ,1
;

-- Cases + Vaccinations

select  coviddeaths2.location as Country, sum(cast(covidvaccinations2.new_vaccinations as signed)) as Vaccinations
from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

group by coviddeaths2.location
order by 2 desc ,1
;

-- Population vs Vaccination

select  coviddeaths2.location as Country, sum(cast(covidvaccinations2.new_vaccinations as signed)) as Vaccinations
, max(cast(coviddeaths2.population as signed)) as Population
, sum(cast(covidvaccinations2.new_vaccinations as signed))/max(cast(coviddeaths2.population as signed))*100 as Vaccination_rate
from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

group by coviddeaths2.location
order by 4 desc ,1
;

-- Population vs Vaccination by Date

select  coviddeaths2.location as Country, 
coviddeaths2.date as date,
coviddeaths2.population as population,
covidvaccinations2.new_vaccinations as Vaccinations,
sum(cast(covidvaccinations2.new_vaccinations as signed)) over(partition by coviddeaths2.location order by coviddeaths2.location,coviddeaths2.date ) as Rolling_total_Vacc  

from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

-- group by coviddeaths2.location
order by 1   ,2
;

-- Use CTE

with PVV (Country, date, population, Vaccinations, Rolling_total_Vacc)
as
(
select  coviddeaths2.location as Country, 
coviddeaths2.date as date,
coviddeaths2.population as population,
covidvaccinations2.new_vaccinations as Vaccinations,
sum(cast(covidvaccinations2.new_vaccinations as signed)) over(partition by coviddeaths2.location order by coviddeaths2.location,coviddeaths2.date ) as Rolling_total_Vacc  

from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

-- group by coviddeaths2.location
-- order by 1   ,2
)
select * , (Rolling_total_Vacc/population)*100 as Vacc_rate
from PVV
;

-- maximum vaccinated country

with PVV (Country, date, population, Vaccinations, Rolling_total_Vacc)
as
(
select  coviddeaths2.location as Country, 
coviddeaths2.date as date,
coviddeaths2.population as population,
covidvaccinations2.new_vaccinations as Vaccinations,
sum(cast(covidvaccinations2.new_vaccinations as signed)) over(partition by coviddeaths2.location order by coviddeaths2.location,coviddeaths2.date ) as Rolling_total_Vacc  

from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

-- group by coviddeaths2.location
-- order by 1   ,2
)
select Country , max((Rolling_total_Vacc/population)*100)as Vacc_rate
from PVV
-- where Country like '%United%'
group by Country
order by 2 desc  ,1
;

-- Temporary table
drop table if exists vaccdata;
create table vaccdata (
Country varchar(255),
date datetime,
population numeric,
Vaccinations numeric,
Rolling_total_Vacc numeric
);
insert into vaccdata (
Country,
date ,
population ,
Vaccinations ,
Rolling_total_Vacc 
)

select  coviddeaths2.location as Country, 
coviddeaths2.date as date,
coviddeaths2.population as population,
covidvaccinations2.new_vaccinations as Vaccinations,
sum(cast(covidvaccinations2.new_vaccinations as signed)) over(partition by coviddeaths2.location order by coviddeaths2.location,coviddeaths2.date ) as Rolling_total_Vacc  

from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

-- group by coviddeaths2.location
-- order by 1   ,2
;
select Country , max((Rolling_total_Vacc/population)*100)as Vacc_rate
from vaccdata
-- where Country like '%United%'
group by Country
order by 2 desc  ,1
;

-- Create view

create view vaccdataview as 
with PVV (Country, date, population, Vaccinations, Rolling_total_Vacc)
as
(
select  coviddeaths2.location as Country, 
coviddeaths2.date as date,
coviddeaths2.population as population,
covidvaccinations2.new_vaccinations as Vaccinations,
sum(cast(covidvaccinations2.new_vaccinations as signed)) over(partition by coviddeaths2.location order by coviddeaths2.location,coviddeaths2.date ) as Rolling_total_Vacc  

from coviddeaths2
left join covidvaccinations2 
on coviddeaths2.location = covidvaccinations2.location
and coviddeaths2.date = covidvaccinations2.date
where coviddeaths2.continent is not null and coviddeaths2.continent <> ''

-- group by coviddeaths2.location
-- order by 1   ,2
)
select * , (Rolling_total_Vacc/population)*100 as Vacc_rate
from PVV
;



