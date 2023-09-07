/*

Cleaning Data in SQL Queries

*/


Select *
From nashvilledb..NashvilleHousingData


-- Populate Property Address data

Select *
From nashvilledb..NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvilledb..NashvilleHousingData a
JOIN  nashvilledb..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvilledb..NashvilleHousingData a
JOIN  nashvilledb..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From nashvilledb..NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as address 
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
	
From nashvilledb..NashvilleHousingData


ALTER TABLE nashvilledb..NashvilleHousingData
Add PropertySplitAddress Nvarchar(200);

Update nashvilledb..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashvilledb..NashvilleHousingData
Add PropertySplitCity Nvarchar(200);

Update nashvilledb..NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select * 
From nashvilledb..NashvilleHousingData

-- owner address

Select OwnerAddress
From nashvilledb..NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashvilledb..NashvilleHousingData


ALTER TABLE nashvilledb..NashvilleHousingData
Add OwnerSplitAddres Nvarchar(200);

Update nashvilledb..NashvilleHousingData
SET OwnerSplitAddres = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE nashvilledb..NashvilleHousingData
Add OwnerSplitCity Nvarchar(200);

Update nashvilledb..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE nashvilledb..NashvilleHousingData
Add OwnerSplitState Nvarchar(100);

Update nashvilledb..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From nashvilledb..NashvilleHousingData



-- Change 1 and 0 to Yes and No in "Sold as Vacant" column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvilledb..NashvilleHousingData
Group by SoldAsVacant


SELECT SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 0 THEN 'No'
        WHEN SoldAsVacant = 1 THEN 'Yes'
        ELSE 'Unknown'
    END AS SoldAsVacant
FROM
    nashvilledb..NashvilleHousingData;

ALTER TABLE nashvilledb..NashvilleHousingData
ADD SoldAsVacantNew VARCHAR(3);


UPDATE nashvilledb..NashvilleHousingData
SET SoldAsVacantNew = CASE
                        WHEN SoldAsVacant = 0 THEN 'No'
                        WHEN SoldAsVacant = 1 THEN 'Yes'
                        ELSE 'Unknown'
                    END;

select *
from nashvilledb..NashvilleHousingData;


-- Delete duplicates

With RownumCte as (
select * ,ROW_NUMBER() over( partition by  ParcelID, 
					PropertyAddress,	
					SalePrice, 
					SaleDate, 
					LegalReference 
					order by UniqueID) row_num
from nashvilledb..NashvilleHousingData


)

select *
from RownumCte
where row_num >1


select *
from nashvilledb..NashvilleHousingData;


--delete unused columns
select *
from nashvilledb..NashvilleHousingData

ALTER TABLE nashvilledb..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant
