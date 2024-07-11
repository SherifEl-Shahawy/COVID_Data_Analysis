Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Death
Select Location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like 'Egypt'
order by 1,2


-- shows what Percentage of Population got Covid 
Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Where location like 'Egypt'
order by 1,2


-- Looking at countries with highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
--Where location like 'Egypt'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count Per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAK THINGS Down By CONTINENT
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where continent is not null and new_cases >= 1
--Group BY date
ORDER BY 1,2


-- USE CTE
With PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, Sum(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE
Drop Table if Exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, Sum(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store date for later Visualtization
Drop View if Exists PercentPopulationVaccinated
Create View  PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, Sum(CONVERT(int, vax.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
--order by 2,3

