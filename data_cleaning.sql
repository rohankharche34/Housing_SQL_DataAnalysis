CREATE DATABASE housing_data;

USE housing_data;

SELECT *
FROM nashville_housing_data;

CREATE TABLE housing_staging
LIKE nashville_housing_data;

INSERT housing_staging
SELECT *
FROM nashville_housing_data;

SELECT *
FROM housing_staging;

-- 1. Removing duplicate values

WITH duplicate_cte AS 
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY uniqueid) AS row_num
FROM housing_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- 2. Standardize the data
SET SQL_SAFE_UPDATES = 0;

UPDATE housing_staging
SET propertyaddress = UPPER(propertyaddress), 
ownername = UPPER(ownername),
owneraddress = UPPER(owneraddress), 
taxdistrict = UPPER(taxdistrict);

SELECT propertyaddress, TRIM(propertyaddress) , OwnerName, TRIM(OwnerName), OwnerAddress , TRIM(OwnerAddress)
FROM housing_staging;

UPDATE housing_staging
SET propertyaddress = TRIM(propertyaddress) ,
OwnerName = TRIM(OwnerName),
OwnerAddress = TRIM(OwnerAddress),
taxdistrict = TRIM(taxdistrict);

SELECT 
   COUNT(*) AS total_owneraddress,
   COUNT(CASE WHEN owneraddress LIKE '%, TN' THEN 1 END) AS tn_owneraddress
FROM housing_staging;

SELECT owneraddress, TRIM(TRAILING ', TN' FROM owneraddress)
FROM housing_staging
ORDER BY 1;

UPDATE housing_staging
SET owneraddress = TRIM(TRAILING ', TN' FROM owneraddress);

SELECT saledate 
FROM housing_staging;

SELECT STR_TO_DATE(`saledate`, '%M %d,%Y')
FROM housing_staging;

UPDATE housing_staging
SET `saledate` = STR_TO_DATE(`saledate`, '%M %d,%Y');

SELECT saleprice, COUNT(*)
FROM housing_staging
GROUP BY saleprice
ORDER BY saleprice DESC;

SELECT *
FROM housing_staging
WHERE yearbuilt <= 0 OR saleprice <= 0;

SELECT soldasvacant
FROM housing_staging
WHERE soldasvacant IN ('Y','y','1','N','n','0');

UPDATE housing_staging
SET soldasvacant = 'YES'
WHERE soldasvacant IN ('Y','y','1','Yes');

UPDATE housing_staging
SET soldasvacant = 'NO'
WHERE soldasvacant IN ('N','n','0','No');

SELECT *
FROM housing_staging
WHERE totalvalue != landvalue + buildingvalue;

UPDATE housing_staging 
SET totalvalue = landvalue + buildingvalue
WHERE totalvalue != landvalue + buildingvalue;

ALTER TABLE housing_staging
ADD CONSTRAINT check_total_value CHECK (totalvalue = landvalue + buildingvalue);

ALTER TABLE housing_staging 
ADD COLUMN Property_age INT;

UPDATE housing_staging
SET property_age = EXTRACT(YEAR FROM saledate) - yearbuilt
WHERE EXTRACT(YEAR FROM saledate) > yearbuilt;

SELECT * 
FROM housing_staging
WHERE property_age IS NULL;

SELECT * 
FROM housing_staging 
WHERE acreage IS NULL;

ALTER TABLE housing_staging
ADD COLUMN Priceperacre DOUBLE;

UPDATE housing_staging
SET priceperacre = saleprice / NULLIF(acreage,0);

SELECT priceperacre , ROUND(priceperacre,4) 
FROM housing_staging;

UPDATE housing_staging
SET priceperacre = ROUND(priceperacre,4);

-- 3. Remove Null values

SELECT *
FROM housing_staging
WHERE propertyaddress IS NULL
AND landvalue IS NULL
AND buildingvalue IS NULL;

-- No relevant null vlaues








