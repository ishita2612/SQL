select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
order by 1,2

--total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where Location like '%ndia'
order by 1,2

-- Looking at total_cases vs Population
select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from [Portfolio Project]..CovidDeaths$
where Location like '%ndia'
order by 1,2

--which countries have highest infection rates wrt population
select Location, Population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as PercentPop
from [Portfolio Project]..CovidDeaths$
group by Location, Population
order by PercentPop DESC

--HOW MANY PERCENTAGE PEOPLE DIED
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by Location
order by TotalDeathCount DESC

--breaking things by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount DESC

----global numbers
select date, sum(new_cases), SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases)
from [Portfolio Project]..CovidDeaths$
where continent is null
group by date
order by 1,2

--total population vs people vaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location)
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccination as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated,
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccination as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using cte

with PopsVacs( continent, location, date, Population, new_vaccinations, rollingpeoplevaccinated)
as(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccination as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/Population)*100 AS pup
from PopsVacs
where location like '%ndia%'
order by pup DESC

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccination as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100 AS pup
from #PercentPopulationVaccinated
--permanent table
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths$ as dea
join [Portfolio Project]..CovidVaccination as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated