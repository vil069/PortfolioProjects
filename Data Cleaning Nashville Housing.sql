/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, SaleDateConvert, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET NashvilleHousing.SaleDate = CONVERT(Date, NashvilleHousing.SaleDate)
--Not working?

ALTER TABLE NashvilleHousing
Add SaleDateConvert Date;

Update NashvilleHousing
SET SaleDateConvert = Convert(Date, SaleDate)
---------------------------------------------------------------------------------------------------
--Populate Property Address data

--Lots of PropertyAddress is NULL!
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

-- ParcelID is a good indicator of PropertyAddress, as Parcels with the same IDs should
-- Also share PropertyAddresses.

--Here, we find rows in a where PropertyAddress is NULL, and join it with a copy of the table
-- to see if there are any NULL PropertyAddresses that can be filled using ParcelID matching.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Here, we update a using ISNULL, which finds null values in a and imputes values from b
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
---------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--This looks at PropertyAddress, starting from position 1 (the very beginning), until the index right before ',' is found,
--and extracts the address. The second SUBSTRING function extracts the city.
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

--Now onto Owner Address
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(OwnerAddress, 1)
From PortfolioProject.dbo.NashvilleHousing
-- Now what does PARSENAME do? Parsename takes in a string and seperates the string by periods. 
-- For example, PARSENAME('test.name', 2) would return 'test', and PARSENAME('test.name', 1) would return name.
-- Consider that the number PARSENAME takes as the 2nd parameter kinda goes backwards.

-- Also, consider that OwnerAddress is, by default, seperated by commas and not periods. 
-- Simply replace them!

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

-- Now to update the table
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------
-- Change Y and N to 'Yes' and 'No' in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

---------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
)
DELETE
from RowNumCTE
Where row_num > 1
--I feel like this would be easier in Python
-- Using pandas, get the duplicates using the above columns by using DataFrame.duplicated()
-- Then extract the indexes for these duplicates, then drop them from the original dataframe.

---------------------------------------------------------------------------------------------------
-- Delete Unused Columns
-- Usually, raw data is not deleted, deletion of data should only really be used for views or temp tables.

Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate