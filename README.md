# Infection Analysis Dashboard

⚠️ **Note:** This repository focuses exclusively on the implementation of the Shiny application developed for the thesis.  
The full statistical methodology and research results are described in the thesis document and are not included here.

Interactive **R Shiny application** developed as part of an undergraduate thesis in **Mathematics**.  
The application provides a visual environment for exploring infection data, analysing longitudinal patient records and interacting with statistical modelling tools.

The repository focuses exclusively on the **implementation and structure of the Shiny application** used in the project.

---

# Project context

This application was developed within the framework of a **Bachelor's thesis in Mathematics**, where the main objective was to study infection dynamics using statistical methods for **panel data and longitudinal observations**.

The research involved a broader statistical workflow including:

- exploratory data analysis
- preprocessing and data preparation
- interpolation of physiological variables
- analysis of infection transitions
- panel data modelling
- estimation of mixed-effects models

However, the complete methodological development and statistical analysis are described in detail in the **written thesis document**.  

For this reason, this repository only contains the **interactive application used to visualise and explore the results**.

---

# Purpose of the repository

The goal of this repository is to present:

- the architecture of the Shiny application
- the interactive visualisation tools implemented
- the structure of the analysis environment
- the modelling interfaces included in the dashboard

The repository **does not include the original datasets** used during the research.

---

# Application features

The Shiny dashboard includes several modules designed to explore infection data and patient observations.

Main functionalities include:

### Exploratory data analysis

Tools for exploring the behaviour of physiological variables and infection records across time.

### Temporal visualisation

Interactive plots showing the evolution of patient measurements and infection events.

### Infection transition analysis

Graph-based visualisation of transitions between infection types.

Network analysis tools allow the study of infection dynamics through patient trajectories.

### Panel data exploration

The application allows the exploration of longitudinal patient data where multiple observations are recorded for each individual.

### Statistical modelling

The application includes interfaces to estimate different statistical models, including:

- logistic regression models
- mixed-effects models
- models for panel data structures

These models allow the study of infection probability while accounting for individual-level variability.

---

# Required data structure

The application was originally designed to work with specific datasets generated during the research project.

These datasets are **not included in this repository**, but the application expects files with a specific structure.

The main datasets used in the application include:

### Patient samples dataset

A dataset containing longitudinal observations for each patient.

Typical variables include:

- `resident_code`
- `sex`
- `age`
- `berthel_index`
- `date_samples`
- `Año`
- `Mes`
- `dia`
- `lapse`
- `Infeccion`
- `body_temp`
- `SPO2.Min`
- `BPM.Avg`
- `EDA.Avg`
- `tmed`
- `sol`
- `presMean`

Each patient may have **multiple observations across time**, allowing longitudinal analysis.

Missing values may appear in physiological variables when measurements are not available.

---

### Infection diagnosis dataset

A dataset containing confirmed infection events.

Typical variables include:

- `resident_code`
- `Institution`
- `Types_of_Infectious`
- `date_diagnosis`

Each patient may have **multiple infection records across time**.

Infections are coded as:

| Code | Infection type |
|-----|-----|
| STI | Skin and Soft Tissue Infection |
| ARI | Acute Respiratory Infection |
| UTI | Urinary Tract Infection |

---

### User authentication file

The application generates a local file used for login authentication:

`usuarios.csv`

Structure:

| usuario | contrasena |
|---------|------------|
| ejemplo | ejemplo123 |



This file is **automatically created by the application when a user registers for the first time**.

# Data availability

The datasets used in the original research are **not included in this repository**.

The repository focuses on the **software implementation of the Shiny application**.  
The data used during the thesis were employed exclusively for academic analysis.

---

# Repository structure

```markdown
infection-analysis-dashboard
│
├── global.R
├── server.R
├── ui.R
├── librerias.R
│
├── helpers/
│ └── modules and analytical functions
│
├── www/
│ └── static resources used by the Shiny interface
│
├── README.md
└── .gitignore
``` 


The code is organised in a modular structure in order to separate:

- data processing
- visualisation components
- modelling interfaces
- auxiliary functions

---

# Technologies used

The project was implemented using the **R programming language** and the **Shiny framework**.

Main libraries used include:

- `shiny`
- `ggplot2`
- `plotly`
- `dplyr`
- `tidyr`
- `igraph`
- `ggraph`
- `lme4`
- `ordinal`
- `DT`

These libraries enable the integration of statistical analysis, interactive visualisation and user interface design within a single application.

---

# Running the application

To run the application locally in R:

```r
shiny::runApp()
``` 

or


```r
runApp("infection-analysis-dashboard")
``` 
# Author: Salma Ghailan Serroukh

Undergraduate thesis project in Mathematics.

The repository contains the implementation of the interactive application developed as part of the research work.
