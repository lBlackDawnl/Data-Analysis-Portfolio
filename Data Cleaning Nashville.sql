/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleData.dbo.[NashvilleHousingData ]

----------------------------------------------------------------------------------------


-- Standardize date format

SELECT Saledate
FROM NashvilleData.dbo.[NashvilleHousingData ] -- remove the time at the end of the date and update it to our table

SELECT Saledate, CONVERT(Date,SaleDate)
FROM NashvilleData.dbo.[NashvilleHousingData ] -- check coverted date properly

Update NashvilleData.dbo.[NashvilleHousingData ] -- Updated table with information above
SET SaleDate = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------

-- Populate Prperty Address data

SELECT PropertyAddress
FROM NashvilleData.dbo.[NashvilleHousingData ] -- Pulls up all propety data

SELECT PropertyAddress
FROM NashvilleData.dbo.[NashvilleHousingData ] -- looking for null values
WHERE PropertyAddress is null          

SELECT *
FROM NashvilleData.dbo.[NashvilleHousingData ] -- We noted that the parcel ID and Property Address are link and there are some dups
--WHERE PropertyAddress is null      -- With this inform, we will try to full some of the Null values if there is a Parcel ID that makes theirs
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData.dbo.[NashvilleHousingData ] a
JOIN NashvilleData.dbo.[NashvilleHousingData ] b -- We must Join with ourseleves to compare values
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID -- We use Unique Ids since they are distinct. The ParcelID will be the same but will ensure it will be a different row
Where a.PropertyAddress	is null
-- We can see that we want the new column using the ISNULL fxn to fill our NULL values due to Parcel ID match.

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData.dbo.[NashvilleHousingData ] a
JOIN NashvilleData.dbo.[NashvilleHousingData ] b 
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress	is null

-- We can run the query above update to ensure the changes hve been made


----------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleData.dbo.[NashvilleHousingData ] -- A delimiter seperates pieces of data, we can see that a comma does that for the Address

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- Looks for the , in PropertyAddress and cuts off the rest. 
-- We added - 1 to the substring to remove the comma as well
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City -- The Len allows us to start after the Address, find the comma and go for using the +1
FROM NashvilleData.dbo.[NashvilleHousingData ]

-- Updating

ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
Add PropertySplitAddress Nvarchar(255);

Update NashvilleData.dbo.[NashvilleHousingData ] 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
Add PropertySplitCity Nvarchar(255);

Update NashvilleData.dbo.[NashvilleHousingData ] 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleData.dbo.[NashvilleHousingData ] --Check the end to see our new tables





------ We are going to look at the Owner Address Now

SELECT OwnerAddress
FROM NashvilleData.dbo.[NashvilleHousingData ] 

--- Going to use parse name rather than Substring again


SELECT -- PARSENAME Looks for '.' so we will use REPLACE to make it look for ','
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1 ) as State,
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)  as City, 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)  as Address
FROM NashvilleData.dbo.[NashvilleHousingData ] 


ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
Add OwnerSplitState Nvarchar(255);

Update NashvilleData.dbo.[NashvilleHousingData ] 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1 )

ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
Add OwnerSplitCity Nvarchar(255);

Update NashvilleData.dbo.[NashvilleHousingData ] 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleData.dbo.[NashvilleHousingData ] 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

SELECT *
FROM NashvilleData.dbo.[NashvilleHousingData ] 



----------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold Vacant" field

SELECT SoldasVacant
FROM NashvilleData.dbo.[NashvilleHousingData ] -- lets us see what values are used in table

SELECT CAST(SoldAsVacant AS CHAR(50)) as converted_char_value
FROM NashvilleData.dbo.[NashvilleHousingData ]

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	   WHEN SoldAsVacant = 0 THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleData.dbo.[NashvilleHousingData ] --- Does not work due to column being a bit



ALTER TABLE  NashvilleData.dbo.[NashvilleHousingData ] 
ADD SoldAsVacantChar VARCHAR(5);

UPDATE NashvilleData.dbo.[NashvilleHousingData ] 
SET SoldAsVacantChar = CASE
	WHEN SoldAsVacant = 1 THEN 'Yes'
	WHEN SoldAsVacant = 0 THEN 'No'
END;


SELECT Distinct(SoldAsVacantChar)
FROM NashvilleData.dbo.[NashvilleHousingData ] 

----------------------------------------------------------------------------------------

-- Remove Duplicates 
-- Usually does not do it in SQL

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleData.dbo.[NashvilleHousingData ]
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
 -- every thing is this list is a dup
-- Our goal is to delete them


----------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM NashvilleData.dbo.[NashvilleHousingData ]
-- Never do to raw data

ALTER TABLE NashvilleData.dbo.[NashvilleHousingData ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress