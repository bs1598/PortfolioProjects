select * from coviddeaths order by 3,4

--select * from covidvaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from coviddeaths 
where location like '%India%'
and continent is not null
order by 1,2

-- Looking at the Total cases vs population
-- Shows what percentage of population got COVID-19
select location, date, population,total_cases,  (total_cases/population)*100 as PercentPopulationInfected 
from coviddeaths 
where location like '%India%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected   
from coviddeaths 
--where location like '%India%'
where continent is not null
group by population, location
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population 

select location, max(total_deaths) as TotalDeathCount    
from coviddeaths 
where continent is not null
group by location
order by TotalDeathCount desc

--Displaying the same data by continent

select continent, max(total_deaths) as TotalDeathCount    
from coviddeaths 
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select   sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as DeathPercentage 
from coviddeaths 
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
--using a CTE

with PopvsVac(continent, location, date, population, New_vaccinations, RollingVaccineCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date ) as RollingVaccineCount
from coviddeaths dea join covidvaccinations vac
on dea.date = vac.date and dea.location=vac.location
where dea.continent is not null
--order by 2,3
)
select *,(RollingVaccineCount/population)*100 as VaccinatedPopPercent from PopvsVac


--using a TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccineCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccineCount
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingVaccineCount/Population)*100 as VaccinatedPopPercent
From #PercentPopulationVaccinated

--- Creating view for further visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

