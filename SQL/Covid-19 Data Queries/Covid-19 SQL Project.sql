/*
Covid-19 Data Exploration in Microsoft SQL Server

Skills used: Converting data types, Aggregate functions, Temp tables, CTE's, Joins, Windows functions, and creating views
*/

--- Looking at the two datasets to ensure they were imported properly

Select *
From [Covid-19 SQL Project]..Covid_Deaths
order by 3,4

Select *
From [Covid-19 SQL Project]..Covid_Vaccinations
order by 3,4

-- Select Data that we will be using and order by the first two columns in the table

Select distinct location, date, total_cases, new_cases, total_deaths, population
From [Covid-19 SQL Project]..Covid_Deaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
Select distinct location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as Percentage_Death
From [Covid-19 SQL Project]..Covid_Deaths
where location like '%states%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select distinct Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Covid-19 SQL Project]..Covid_Deaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select distinct Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid-19 SQL Project]..Covid_Deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select distinct Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid-19 SQL Project]..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid-19 SQL Project]..Covid_Deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL COVID CASE NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid-19 SQL Project]..Covid_Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one dosage of Covid Vaccine

Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid-19 SQL Project]..Covid_Deaths dea
Join [Covid-19 SQL Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid-19 SQL Project]..Covid_Deaths dea
Join [Covid-19 SQL Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in the previous query

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
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid-19 SQL Project]..Covid_Deaths dea
Join [Covid-19 SQL Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating a View to store data for later visualizations

USE [Covid-19 SQL Project]
GO
Create View PercentPopulation_Vaccinated as
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid-19 SQL Project]..Covid_Deaths dea
Join [Covid-19 SQL Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
