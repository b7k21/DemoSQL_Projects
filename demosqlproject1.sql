
select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2


-- total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like'%ethiopia%'
order by 1,2

-- total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like'%ethiopia%'
order by 1,2
-- Countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as HigestInfectionCount,max( (total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
group by location,population
--where location like'%ethiopia%'
order by PercentPopulationInfected desc

-- highest death count per population
select location,max(cast(total_deaths as int))  as TotalDeathCount
from CovidDeaths
--where location like'%ethiopia%'
where continent is not null
group by location
order by TotalDeathCount desc
-- total death count by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global numbers
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_death,sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3
-- using CTE
with popuvsvac(continent,location,date,population,ew_vaccinations,RollingpeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
select *,(RollingpeopleVaccinated/population)*100 as TotalPopulationComapredtovaccined
from popuvsvac

-- using temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as RollingpeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
--where cd.continent is not null
--order by 2,3
select *,(RollingpeopleVaccinated/population)*100 as TotalPopulationComapredtovaccined
from #PercentPopulationVaccinated


-- using view to store data

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from PercentPopulationVaccinated