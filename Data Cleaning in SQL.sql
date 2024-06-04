/*

Cleaning Data in SQL Queries 

*/

Select *
From portfolioProject..nashvillehousing


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From portfolioproject..nashvillehousing 

Update nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(Date,SaleDate)


--Populate Property Address Data

Select *
From portfolioproject..nashvillehousing 
Where PropertyAddress is null
order by ParcelID

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)
From portfolioproject..nashvillehousing a
join portfolioproject..nashvillehousing b
   on a.ParcelID=b.ParcelID
   and a.[UniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null

update a
SET PropertyAddress=ISNULL(a.propertyaddress,b.propertyaddress)
From portfolioproject..nashvillehousing a
join portfolioproject..nashvillehousing b
   on a.ParcelID=b.ParcelID
   and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into individual coloumns (Address, City, State) method 1

Select PropertyAddress
From portfolioproject..NashvilleHousing

Select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
From portfolioproject..NashvilleHousing

Select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
 SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From portfolioproject..NashvilleHousing

use portfolioproject

ALTER TABLE NashvilleHousing
DROP COLUMN PropertySplitAddress;
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
DROP COLUMN PPropertySplitCity;

Select *
From portfolioproject..nashvillehousing 


-- alt method to split long strings method 2

Select OwnerAddress
From portfolioproject..nashvillehousing 

Select OwnerAddress
From portfolioproject..nashvillehousing 

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2), -- we replace , with . since parsename only deals with periods
PARSENAME(REPLACE(OwnerAddress,',','.'),1) --doing 3 2 1 orders it in proper format instead of giving the reverse output
From portfolioproject..nashvillehousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes ad No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolioproject..nashvillehousing 
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case When SoldAsVacant ='Y' THEN 'Yes'
     When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant 
	 END
From portfolioproject..nashvillehousing 

Update nashvillehousing
Set SoldAsVacant=Case When SoldAsVacant ='Y' THEN 'Yes'
     When SoldAsVacant ='N' THEN 'No'
	 Else SoldAsVacant 
	 END


-- Removing Duplicates

WITH RowNumCTE As(
 Select *,
    ROW_NUMBER()OVER(
	Partition By ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID)row_num


From portfolioproject..nashvillehousing 
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num>1
order by PropertyAddress -- we find out duplicates 


WITH RowNumCTE As(
 Select *,
    ROW_NUMBER()OVER(
	Partition By ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID)row_num


From portfolioproject..nashvillehousing 
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num>1
--order by PropertyAddress 
-- now we delete


-- Delete Unused Coloumns [do not do this unless absolutely sure]

 Select *
From portfolioproject..nashvillehousing 

ALTER TABLE portfolioproject..nashvillehousing 
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE portfolioproject..nashvillehousing 
DROP COLUMN SaleDate

ALTER TABLE portfolioproject..nashvillehousing 
DROP COLUMN salesdateconverted
