select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--showsthe likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as dethpercentage
from CovidDeaths
where location like '%ghana%'
order by 1,2

--looking at the total cases vs the population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from CovidDeaths
where location like '%ghana%'
order by 1,2

--looking at countries with highest infection rate

select location,population, max(total_cases) as highestinfectioncount, max((total_cases /population))*100 as percentpopulationinfected
from CovidDeaths
group by location, population
order by percentpopulationinfected desc


--showing the countries with the highest death count per population

select location, MAX(cast(total_deaths As int)) as totaldeathcount
from CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc



--LETS BREAK IT DOWN BY CONTINENT 
--showing continents with highest death count

select continent, MAX(cast(total_deaths As int)) as totaldeathcount
from CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select Sum(new_cases) as sumofnewcases, SUM(cast(new_deaths AS int)) as sumofnewdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage --total_deaths,(total_deaths/total_cases)*100 as dethpercentage
from CovidDeaths
--where location like '%ghana%'
Where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  like '%africa%'
order by 2,3


--CREATE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  like '%africa%'
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


--temp table
drop table if exists #percentpopulationvaccinated

Create table #percentpopulationvaccinated 
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rollongpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  like '%africa%'

select *, (rollongpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualization

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent  is not null

select *
from percentpopulationvaccinated 