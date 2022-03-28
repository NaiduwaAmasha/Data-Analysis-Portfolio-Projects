 -- Cleaning data in sql queries

 select *  
  from DataVizPortfolioProject..NashvilleHousing

 -- standarlize date format
 select saledate, convert(Date,SaleDate)
 from DataVizPortfolioProject..NashvilleHousing

 update DataVizPortfolioProject..NashvilleHousing
 set SaleDate = convert(Date, saleDate)

 -- populate property address data
 select *
 from DataVizPortfolioProject..NashvilleHousing
  -- where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
  from DataVizPortfolioProject..NashvilleHousing a
  join DataVizPortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  update a
  set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  from DataVizPortfolioProject..NashvilleHousing a
  join DataVizPortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  -- breaking out address into individual columns(Address, City,state)
  select PropertyAddress
  from DataVizPortfolioProject..NashvilleHousing
  -- where PropertyAddress is null
  -- order by ParcelID

  select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
  from DataVizPortfolioProject..NashvilleHousing

  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  Add PropertySplitAddress NVARCHAR(255)

 update DataVizPortfolioProject..NashvilleHousing
 set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

 
  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  Add PropertySplitCity NVARCHAR(255) 

 update DataVizPortfolioProject..NashvilleHousing
 set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

  select *  
  from DataVizPortfolioProject..NashvilleHousing


  -- simple way for substring
  select
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
  from DataVizPortfolioProject..NashvilleHousing
  
  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  Add OwnerSplitAddress NVARCHAR(255) 

  update DataVizPortfolioProject..NashvilleHousing
  set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  Add OwnerSplitCity NVARCHAR(255) 

  update DataVizPortfolioProject..NashvilleHousing
  set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  ADD OwnerSplitState NVARCHAR(255) 

  update DataVizPortfolioProject..NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

  ALTER TABLE DataVizPortfolioProject..NashvilleHousing
  DROP COLUMN OwnerSplitState

  --Change Y and N to Yes and No in "Sold as Vacant" field
   select DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
   from DataVizPortfolioProject..NashvilleHousing
   Group By SoldAsVacant
   Order by 2

   select SoldAsVacant
   , CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
   from DataVizPortfolioProject..NashvilleHousing

  update DataVizPortfolioProject..NashvilleHousing
  SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

 -- Remove Duplicates
   select *
   from DataVizPortfolioProject..NashvilleHousing

   WITH RowNumCTE AS(
   select *,
   ROW_NUMBER() Over (
   PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER  BY
					UniqueID
   ) row_num
   from DataVizPortfolioProject..NashvilleHousing 
   -- ORDER BY ParcelID
   )
   select *
   from RowNumCTE
   where row_num > 1
   order by PropertyAddress

   -- Delete unused columns
   select *
   from DataVizPortfolioProject..NashvilleHousing

   ALTER TABLE DataVizPortfolioProject..NashvilleHousing
   DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

   ALTER TABLE DataVizPortfolioProject..NashvilleHousing
   DROP COLUMN SaleDate
