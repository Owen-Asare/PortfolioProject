/*

CLEANING DATA In SQL

*/

USE PortfolioProject;

SELECT *
FROM NashvilleHousing



-- 1.Standardising Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) as SaleDateFormatted
FROM NashvilleHousing


-- Crete a new column named SaleDateFormatted
ALTER TABLE NashvilleHousing
ADD SaleDateFormatted Date


-- Updating the new column with the data of the old SaleDate data
UPDATE NashvilleHousing
SET SaleDateFormatted = CONVERT(Date, SaleDate)



-- 2. Populate Property Address Data

-- Self join the the table to find the values of the Property Address to be populated with the same data
SELECT tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress 
FROM NashvilleHousing tab1
JOIN NashvilleHousing tab2
	ON tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] != tab2.[UniqueID ]
WHERE tab1.PropertyAddress IS NULL

/*
	In order to populate the empty data in the PropetyAddress column, we update the null
	fields with data of the same column from the join statetment above
	Since from research, all the properties with the same parcelid have the same property address
*/
UPDATE tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress, tab2.PropertyAddress)
FROM NashvilleHousing tab1
JOIN NashvilleHousing tab2
	ON tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID ] != tab2.[UniqueID ]
WHERE tab1.PropertyAddress IS NULL


-- 3.Extracting Address Into Individual Column Name (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing


-- Using Substring, the Property Address is then split into the Address and the City
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing


-- Create a new column for the address of the property
ALTER TABLE NashvilleHousing
ADD PropertyAddress1 nvarchar(255)

-- Put values into the new column created
UPDATE NashvilleHousing
SET PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


-- Create a new column for the city
ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255)

-- Put values into the new column created
UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing


/*
Alternatively, you can use the PARSENAME function to split the address into it's individual forms.
Using the PARSENAME, all other delimiters must be replaced with a period(.) if they not already that.
 NB PARSENAME does it splits in backwards indexig
*/

-- Use PARSENAME to split the Address
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddress1 nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- 4.Changing Y and N To Yes and No

-- SElect the distinct values and count the total number of Y, N, No and Yes in the SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)


-- Using the case statement, when put Yes if the value is Y and No if the value is N
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

-- Update the SoldAsVacant Column
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END



-- 5. Find And Remove Duplicate

-- Finding The Duplicates
WITH RowNum_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				 ORDER BY
				 UniqueID) as RowNum
FROM NashvilleHousing
)
SELECT * 
FROM RowNum_CTE
WHERE RowNum > 1
ORDER BY PropertyAddress


-- Deleting The Duplicates
WITH RowNum_CTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				 ORDER BY
				 UniqueID) as RowNum
FROM NashvilleHousing
)
DELETE 
FROM RowNum_CTE
WHERE RowNum > 1
--ORDER BY PropertyAddress



-- 6. Removing Unwanted Column
SELECT *
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate,OwnerAddress



EXEC sp_rename 'NashvilleHousing.OwnerAddress1','OwnerAddress', 'COLUMN';