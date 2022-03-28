 -- Check dataset
 SELECT * 
 FROM DataVizPortfolioProject..UnEmploymentRate$;
 

 --Format Quaterly data into MM-YYYY

SELECT CONCAT(PARSENAME(REPLACE(Time1, '-', '.') , 1),
CASE PARSENAME(REPLACE(Time1, '-', '.') , 2)
       WHEN 'Q1' THEN '-03-31'
       WHEN 'Q2' THEN '-06-30'
       WHEN 'Q3' THEN '-09-30'
       ELSE  '-12-31' END) as FormatDate
 FROM DataVizPortfolioProject..[UnEmploymentRate$];

 --Add Column
  ALTER TABLE  DataVizPortfolioProject..[UnEmploymentRate$]
  DROP COLUMN FormatDate;
  ALTER TABLE DataVizPortfolioProject..[UnEmploymentRate$]
  ADD FormatDate DATE;

  --Change the format of the date
  Update DataVizPortfolioProject..[UnEmploymentRate$]
  SET FormatDate = CONCAT(PARSENAME(REPLACE(Time1, '-', '.') , 1),
  CASE PARSENAME(REPLACE(Time1, '-', '.') , 2)
       WHEN 'Q1' THEN '-03-31'
       WHEN 'Q2' THEN '-06-30'
       WHEN 'Q3' THEN '-09-30'
       ELSE  '-12-31' END) 
  FROM DataVizPortfolioProject..[UnEmploymentRate$];


 -- breaking Subject1 gender wise
  SELECT
  SUBSTRING(Subject1,1, CHARINDEX(',', Subject1, CHARINDEX(',', Subject1)+1)-1) as Type, 
  SUBSTRING(Subject1, CHARINDEX(',', Subject1, CHARINDEX(',', Subject1) +1)+1, LEN(Subject1)) as Gender 
  from DataVizPortfolioProject..[UnEmploymentRate$];

  -- Add the new column 'Type'
  ALTER TABLE  DataVizPortfolioProject..[UnEmploymentRate$]
  DROP COLUMN SubjectSplitType;

  ALTER TABLE DataVizPortfolioProject..[UnEmploymentRate$]
  ADD SubjectSplitType NVARCHAR(255)

  --Update the Type column
  Update DataVizPortfolioProject..[UnEmploymentRate$]
  SET SubjectSplitType = SUBSTRING(Subject1,1, CHARINDEX(',', Subject1, CHARINDEX(',', Subject1)+1)-1);

 
 -- Change the table to add new column 'Gender'
  ALTER TABLE  DataVizPortfolioProject..[UnEmploymentRate$]
  DROP COLUMN SubjectSplitGender;

  ALTER TABLE DataVizPortfolioProject..[UnEmploymentRate$]
  ADD SubjectSplitGender NVARCHAR(255);

  UPDATE DataVizPortfolioProject..[UnEmploymentRate$]
  SET SubjectSplitGender =   SUBSTRING(Subject1, CHARINDEX(',', Subject1, CHARINDEX(',', Subject1) +1)+1, LEN(Subject1))

 --Check the changes
  SELECT * 
  FROM DataVizPortfolioProject..[UnEmploymentRate$];

  --Remove Duplicates
  SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                Location, 
                Subject, 
                PowerCode,
				FormatDate,
				Measure,
				Value
            ORDER BY 
				Location,
				Subject
        ) row_num
     FROM 
        DataVizPortfolioProject..[UnEmploymentRate$];
-- No Duplicates were present

--Delete unused columns
   ALTER TABLE  DataVizPortfolioProject..UnEmploymentRate$
   DROP COLUMN Time1, Frequency;

 -- Let's start Visulization

 --Check cleaned dataset
  SELECT * 
  FROM DataVizPortfolioProject..[UnEmploymentRate$];

  -- Get Average unemployment rate from the contries - Female wise
  SELECT country, AVG(Value) as TotalUnEmployment, SubjectSplitGender
  FROM DataVizPortfolioProject..[UnEmploymentRate$]
  Where (SubjectSplitGender = ' Females' OR SubjectSplitGender = ' Males') AND country not in ('Euro area', 'Euro area (19 countries)','European Union – 27 countries (from 01/02/2020)', 'G7', 'OECD - Total')
  GROUP BY country, SubjectSplitGender
  ORDER BY SubjectSplitGender;

  -- Get Average unemployment rate from the contries - Male Wise
  SELECT country, AVG(Value) as AvgUnEmploymentRate, SubjectSplitGender
  FROM DataVizPortfolioProject..[UnEmploymentRate$]
  Where SubjectSplitGender = ' Males' AND country not in ('Euro area', 'European Union – 27 countries (from 01/02/2020)', 'G7', 'OECD - Total')
  GROUP BY country, SubjectSplitGender
  ORDER BY SubjectSplitGender;

  -- Compare the unemployemnt during covid periods
  SELECT uen.Country, AVG(uen.Value) as AvgUnEmploymentRate, uen.SubjectSplitGender, uen.FormatDate, AVG(cd.total_cases) as AvgTotalCases
  FROM DataVizPortfolioProject..UnEmploymentRate$ uen
  INNER JOIN DataVizPortfolioProject..['covid-deaths$'] cd
	ON uen.FormatDate = cd.date
   WHERE uen.SubjectSplitGender = ' All persons'
   GROUP BY Country, SubjectSplitGender, FormatDate;

  
 



