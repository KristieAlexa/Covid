Select *
From dbo.CovidD$
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidD$
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the US

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidD$
Where location = 'United States'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in US

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidD$ 
Where location = 'United States'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidD$
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidD$
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidD$ 
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidD$
where continent is not null 
order by 1,2



-- Shows Total vaccinations

Select CovidD$.continent, CovidD$.location, CovidD$.date, CovidD$.population, CovidV$.new_vaccinations
, SUM(CONVERT(bigint,CovidV$.new_vaccinations)) OVER (Partition by CovidD$.Location Order by CovidD$.location, CovidD$.Date) as RollingPeopleVaccinated
From CovidD$
Join CovidV$
	On CovidD$.location = CovidV$.location
	and CovidD$.date = CovidV$.date
where CovidD$.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CovidD$.continent, CovidD$.location, CovidD$.date, CovidD$.population, CovidV$.new_vaccinations
, SUM(CONVERT(bigint,CovidV$.new_vaccinations)) OVER (Partition by CovidD$.Location Order by CovidD$.location, CovidD$.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidD$
Join CovidV$ 
	On CovidD$.location = CovidV$.location
	and CovidD$.date = CovidV$.date
where CovidD$.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentofPopVaxxed
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select CovidD$.continent, CovidD$.location, CovidD$.date, CovidD$.population, CovidV$.new_vaccinations
, SUM(CONVERT(bigint,CovidV$.new_vaccinations)) OVER (Partition by CovidD$.Location Order by CovidD$.location, CovidD$.Date) as RollingPeopleVaccinated
From CovidD$ 
Join CovidV$
	On CovidD$.location = CovidV$.location
	and CovidD$.date = CovidV$.date
where CovidD$.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentofPopVaxxed
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select CovidD$.continent, CovidD$.location, CovidD$.date, CovidD$.population, CovidV$.new_vaccinations
, SUM(CONVERT(int,CovidV$.new_vaccinations)) OVER (Partition by CovidD$.Location Order by CovidD$.location, CovidD$.Date) as RollingPeopleVaccinated
From CovidD$
Join CovidV$ 
	On CovidD$.location = CovidV$.location
	and CovidD$.date = CovidV$.date
where CovidD$.continent is not null 

































































