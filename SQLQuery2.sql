select *
from CovidDeaths
order by 3,4
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathperecentage
from CovidDeaths
where location like '%states%'
order by 1,2
select location,date,total_cases,population,(total_cases/population)*100 as deathperecentage
from CovidDeaths
where location like '%states%'
order by 1,2
select location,max(total_cases) as highinfectioncount,population,max((total_cases/population))*100 as perecentagepopulationinfected
from CovidDeaths
--where location like '%states%'
Group by location, population
ORDER BY perecentagepopulationinfected desc
select location,max(total_cases) as highinfectioncount,population,max((total_cases/population))*100 as perecentagepopulationinfected
from CovidDeaths
--where location like '%states%'
Group by location, population
ORDER BY perecentagepopulationinfected desc
select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
ORDER BY totaldeathcount desc
select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
ORDER BY totaldeathcount desc
select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is null
Group by location
ORDER BY totaldeathcount desc
select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
ORDER BY totaldeathcount desc
select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
ORDER BY totaldeathcount desc
select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is null
Group by location
ORDER BY totaldeathcount desc
select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
ORDER BY totaldeathcount desc
--Globl numbes
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as deathperecentage
from CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2
--looking at total population vs vaccinations
select *
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date

select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   order by 2,3

   select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location)
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location)
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   order by 2,3

--use cte
with popvsvacc (contient,location,date,population,new_vaccinations,rollingpeoplevaccation)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccation
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   --order by 2,3
   )
   select *
   from popvsvacc

with popvsvacc (contient,location,date,population,new_vaccinations,rollingpeoplevaccation)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccation
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   where dea.continent is not null
   --order by 2,3
   )
   select *,(rollingpeoplevaccation/population)*100
   from popvsvacc

   -- Temp table
drop table if exists #percentpopulationvaccination
create table #percentpopulationvaccination
  (
  contient nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric
  rollingpeoplevaccation numeric
  )

insert into #percentpopulationvaccination
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccation
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
   --where dea.continent is not null
   --order by 2,3
 
select *,(rollingpeoplevaccation/population)*100
from #percentpopulationvaccination

--creating view to store data for later visualizations
create view percentpopulationvaccination as
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as rollingpeoplevaccation
from owiedcovied vacc
join CovidDeaths dea
   on vacc.location = dea.location
   and vacc.date = dea.date
where dea.continent is not null
--order by 2,3
 
 select *
 from percentpopulationvaccination