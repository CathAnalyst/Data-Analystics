---Data Cleaning in SQL---


--Check Data
Select*
From NashvilleHousing



--Standardize Date Format
Select SaleDate, convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = convert(date, SaleDate)



--Populate Property Address
Select first.ParcelID, first.PropertyAddress, second.ParcelID,  second.PropertyAddress, isnull (first.PropertyAddress, second.PropertyAddress)
From PortfolioProject..NashvilleHousing first
Join PortfolioProject..NashvilleHousing second
	On first.ParcelID = second.ParcelID
	and first.[UniqueID ] <> second.[UniqueID ]
Where first.PropertyAddress is null

Update first
Set PropertyAddress = isnull(first.PropertyAddress, second.PropertyAddress)
From PortfolioProject..NashvilleHousing first
Join PortfolioProject..NashvilleHousing second
	On first.ParcelID = second.ParcelID
	and first.[UniqueID ] <> second.[UniqueID ]
Where first.PropertyAddress is null



--Using Substring - Break Address to Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
	Substring(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255), 
	PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1),
	PropertySplitCity = Substring(PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))



--Using ParseName - Break Address to Individual Columns (Address, City, State)
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.'), 3),
	PARSENAME(Replace(OwnerAddress,',','.'), 2),
	PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255), 
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)



--Change Y and N to Yes and No
Select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
					When SoldAsVacant = 'N' then 'No'
					Else SoldAsVacant
					End



--Using CTE - Remove Duplicates
With RowNumCTE As
(
	Select *, ROW_NUMBER() over (
		Partition by	ParcelID, 
						PropertyAddress, 
						SalePrice, SaleDate, 
						LegalReference 
						Order by 
							UniqueID
						) row_num
	From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1



--Delete Unused Columns
Select *
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Drop Column	OwnerAddress,
			TaxDistrict,
			PropertyAddress,
			SaleDate


--END--
