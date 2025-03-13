select *
from PortfolioProject..[NashvilleHousing ]

-- Standardize Data Format

select SaleDate
from PortfolioProject..[NashvilleHousing ]

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] a
Join PortfolioProject..[NashvilleHousing ] b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..[NashvilleHousing ] a
Join PortfolioProject..[NashvilleHousing ] b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..[NashvilleHousing ]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from PortfolioProject..[NashvilleHousing ]

-- Update table


ALTER TABLE PortfolioProject..[NashvilleHousing ]
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..[NashvilleHousing ]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..[NashvilleHousing ]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..[NashvilleHousing ]
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Breaking out OwnerAddress into Individual Columns (Address, City, State)


Select PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
,PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
from PortfolioProject..[NashvilleHousing ]


-- Update table


ALTER TABLE PortfolioProject..[NashvilleHousing ]
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..[NashvilleHousing ]
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

ALTER TABLE PortfolioProject..[NashvilleHousing ]
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..[NashvilleHousing ]
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject..[NashvilleHousing ]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..[NashvilleHousing ]
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1);

Select *
from PortfolioProject..[NashvilleHousing ]


------------------------------------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "SoldAsVacant" Field
-- Check unique value in "SoldAsVacant"
 
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..[NashvilleHousing ]
group by SoldAsVacant


Select SoldAsVacant
,CASE When SoldAsVacant = 0 Then 'No'
      When SoldAsVacant = 1 Then 'Yes'
	  End
from PortfolioProject..[NashvilleHousing ]


ALTER TABLE PortfolioProject..[NashvilleHousing]
ALTER COLUMN SoldAsVacant VARCHAR(3);

Update PortfolioProject..[NashvilleHousing ]
Set SoldAsVacant = CASE When SoldAsVacant = 0 Then 'No'
      When SoldAsVacant = 1 Then 'Yes'
	  End

------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
    ROW_NUMBER() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				    UniqueID
					) Row_num
From PortfolioProject..[NashvilleHousing ]
)
select *
from RowNumCTE
where Row_num > 1
Order by PropertyAddress