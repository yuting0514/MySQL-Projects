USE `Nashville Housing`;
SET SQL_SAFE_UPDATES = 0;

-- Standardize dates
Update NashvilleHousing 
SET SaleDate = STR_TO_DATE(SaleDate, '%d-%b-%y')
WHERE PK <> "";

-- Fill value for NULL Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update NashvilleHousing a 
LEFT JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Split Property Address
SELECT SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) - 1),
	   SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress))
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) - 1)
WHERE PK <> "";

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress))
WHERE PK <> "";

-- Split Owner Address
SELECT substring_index(OwnerAddress, ',', 1),
	   substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
       substring_index(OwnerAddress, ',', -1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OnwerSplitAddress VARCHAR(255);
UPDATE NashvilleHousing
SET OnwerSplitAddress = substring_index(OwnerAddress, ',', 1)
WHERE PK <> "";

ALTER TABLE NashvilleHousing
ADD OnwerSplitCity VARCHAR(255);
UPDATE NashvilleHousing
SET OnwerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1)
WHERE PK <> "";

ALTER TABLE NashvilleHousing
ADD OnwerSplitState VARCHAR(255);
UPDATE NashvilleHousing
SET OnwerSplitState = substring_index(OwnerAddress, ',', -1)
WHERE PK <> "";

-- Change Y, N to Yes, No for SoldAsVacant
SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing;

Update NashvilleHousing 
SET SoldAsVacant = 'No'
WHERE PK <> "" and SoldAsVacant = 'N';

Update NashvilleHousing 
SET SoldAsVacant = 'Yes'
WHERE PK <> "" and SoldAsVacant = 'Y';

-- Remove Duplicates
SELECT *,
	   ROW_NUMBER() OVER(
       PARTITION BY ParcelID,
					PropertyAddress,
                    SaleDate,
                    SalePrice,
                    LegalReference
                    ORDER BY
                    UniqueID) AS row_num
FROM NashvilleHousing;

WITH RowNumCTE AS(
SELECT *,
	   ROW_NUMBER() OVER(
       PARTITION BY ParcelID,
					PropertyAddress,
                    SaleDate,
                    SalePrice,
                    LegalReference
                    ORDER BY
                    UniqueID) AS row_num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE
WHERE row_num >1;

DELETE from NashvilleHousing
WHERE UniqueID IN(
SELECT UniqueID
FROM(SELECT UniqueID,
			ROW_NUMBER() OVER(
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SaleDate,
						 SalePrice,
						 LegalReference
						 ORDER BY
						 UniqueID) AS row_num
			FROM NashvilleHousing) s
WHERE row_num >1);

-- Remove Unnecessary Columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN SaleDate, 
DROP COLUMN TaxDistrict;






