--Standardize Date Format--


UPDATE Nashville_Housing
SET SaleDate = CONVERT(DATE,SaleDate);

ALTER TABLE Nashville_Housing
ADD SaleDateConverted DATE;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(DATE,SaleDate);

--Populate Property Address Data--


UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM Portfolio_project.dbo.Nashville_Housing a
	JOIN Portfolio_project.dbo.Nashville_Housing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Breaking out Address into Individual Coulumms (Address, City, State)--


ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 );

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

--Change Y and N to Yes and No in "Sold as Vacant" field--


UPDATE Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


----Remove Duplicates----


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

FROM Portfolio_Project.dbo.Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

----Delete Unused Columns----


ALTER TABLE Portfolio_Project.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;