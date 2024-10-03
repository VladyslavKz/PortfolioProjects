/*
			SQL Data Cleaning Project: Task List

1)Standardize the date format to ensure consistency across the dataset.

2)Identify missing values in key fields and fill them using related data from other records.

3)Separate combined address data into distinct columns for better organization and analysis.

4)Standardize categorical values to improve readability and consistency.

5)Identify and remove duplicate entries to ensure data uniqueness and accuracy.

6)Eliminate unnecessary columns that are no longer relevant to the analysis.

*/


--Cleaning data using SQL

SELECT * 
FROM Portfolio_Projects..Housing_data

-------------------------------------------------------------------------------------------
--1)Standardize the date format to ensure consistency across the dataset.

SELECT SaleDateConverted,
	CAST(SaleDate as date)
FROM Portfolio_Projects..Housing_data



ALTER TABLE Housing_data
	ADD SaleDateConverted Date;

UPDATE Housing_data
	SET SaleDateConverted = CAST(SaleDate as date)

-------------------------------------------------------------------------------------------
--2)Identify missing values in key fields and fill them using related data from other records.

SELECT *
FROM Portfolio_Projects..Housing_data
WHERE PropertyAddress IS NULL


SELECT a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Projects..Housing_data a
JOIN Portfolio_Projects..Housing_data b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Projects..Housing_data a
JOIN Portfolio_Projects..Housing_data b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------
--3)Separate combined address data into distinct columns for better organization and analysis.

SELECT PropertyAddress
FROM Portfolio_Projects..Housing_data

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  AS City
FROM Portfolio_Projects..Housing_data


ALTER TABLE Portfolio_Projects..Housing_data
	ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Projects..Housing_data
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio_Projects..Housing_data
	ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Projects..Housing_data
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



--Owner address

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Portfolio_Projects..Housing_data


ALTER TABLE Portfolio_Projects..Housing_data
	ADD OwnerPropSplitAddress Nvarchar(255);

UPDATE Portfolio_Projects..Housing_data
	SET OwnerPropSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE Portfolio_Projects..Housing_data
	ADD OwnerPropSplitCity Nvarchar(255);

UPDATE Portfolio_Projects..Housing_data
	SET OwnerPropSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER TABLE Portfolio_Projects..Housing_data
	ADD OwnerPropSplitState Nvarchar(255);

UPDATE Portfolio_Projects..Housing_data
	SET OwnerPropSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

-------------------------------------------------------------------------------------------
--4)Standardize categorical values to improve readability and consistency.
--Change Y and N to Yes or Not in "Sold is vacant" field

SELECT distinct(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM Portfolio_Projects..Housing_data
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ElSE SoldAsVacant
	END
FROM Portfolio_Projects..Housing_data

UPDATE Portfolio_Projects..Housing_data
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ElSE SoldAsVacant
	END

-------------------------------------------------------------------------------------------
--5)Identify and remove duplicate entries to ensure data uniqueness and accuracy.


WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelId,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueId
		) row_num
	FROM Portfolio_Projects..Housing_data
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------------------
--6)Eliminate unnecessary columns that are no longer relevant to the analysis.

ALTER TABLE Portfolio_Projects..Housing_data
DROP COLUMN OwnerAddress, TaxDistrict