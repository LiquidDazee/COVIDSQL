select count(continent) from CovidDeaths;

use COVID;

describe CovidDeaths;

LOAD DATA LOCAL INFILE  
'D:/Downloads/CovidDeaths.csv'
INTO TABLE CovidDeaths  
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(iso_code,continent,location,date,population,total_cases,new_cases,new_cases_smoothed,total_deaths,new_deaths,new_deaths_smoothed,total_cases_per_million,new_cases_per_million,new_cases_smoothed_per_million,total_deaths_per_million,new_deaths_per_million,new_deaths_smoothed_per_million,reproduction_rate,icu_patients,icu_patients_per_million,hosp_patients,hosp_patients_per_million,weekly_icu_admissions,weekly_icu_admissions_per_million,weekly_hosp_admissions,weekly_hosp_admissions_per_million);

LOAD DATA LOCAL INFILE  
'D:/Downloads/CovidVaccinations.csv'
INTO TABLE CovidVaccinations
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(iso_code,continent,location,date,total_tests,new_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,total_boosters,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,total_boosters_per_hundred,new_vaccinations_smoothed_per_million,new_people_vaccinated_smoothed,new_people_vaccinated_smoothed_per_hundred,stringency_index,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index,population,excess_mortality_cumulative_absolute,excess_mortality_cumulative,excess_mortality,excess_mortality_cumulative_per_million);

SET GLOBAL local_infile=1;

DROP Table CovidVaccines;

CREATE TABLE CovidDeaths (
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population BIGINT,
    total_cases BIGINT,
    new_cases BIGINT,
    new_cases_smoothed BIGINT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    new_deaths_smoothed BIGINT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients BIGINT,
    icu_patients_per_million FLOAT,
    hosp_patients BIGINT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions BIGINT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions BIGINT,
    weekly_hosp_admissions_per_million FLOAT
);

CREATE TABLE CovidVaccinations (
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    total_tests BIGINT,
    new_tests BIGINT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed BIGINT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(255),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    total_boosters BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    total_boosters_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    new_people_vaccinated_smoothed BIGINT,
    new_people_vaccinated_smoothed_per_hundred FLOAT,
    stringency_index FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT,
    population BIGINT,
    excess_mortality_cumulative_absolute FLOAT,
    excess_mortality_cumulative FLOAT,
    excess_mortality FLOAT,
    excess_mortality_cumulative_per_million FLOAT
);

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths 
order by 1,2;

select * from CovidDeaths where location = 'Asia'

update CovidDeaths set continent = NULL where location IN ('Asia', 'World', 'High income', 'Upper middle income', 'Europe', 'North America', 'Lower middle income', 'South America', 'European Union', 'Africa', 'Low income', 'Oceania', 'International'); 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from CovidDeaths 
Where location like '%india%'
order by 1,2;

-- Total Cases vs Population
-- Shows percentage of population with Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercent
from CovidDeaths 
Where location like '%states%'
order by 1,2;

-- Looking at Countries with Highest Infection Rate vs Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidPercent
from CovidDeaths 
-- Where location like '%states%'
group by location, population
order by CovidPercent DESC;

--Showing Countries With Highest Death Count per Population

Select location, max(total_deaths) as TotalDeathCount
from CovidDeaths 
where continent <> ''
-- Where location like '%states%'
group by location
order by TotalDeathCount DESC;

--Showing Continent With Highest Death Count per Population

Select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths 
where continent is not null
-- Where location like '%states%'
group by continent
order by TotalDeathCount DESC;


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
from CovidDeaths
where continent is not null
group by date
order by 1;


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac;

Select *
from PercentPopulationVaccinated;