/*
Cleaning Data In SQL Queries
*/

select *
from NashvilleHousing


-- Updated Date Format

select SaleDate, CONVERT(date, SaleDate)
from NashvilleHousing


update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted --CONVERT(date, SaleDate)
from NashvilleHousing


-- Populate Property Address Data

select *
from NashvilleHousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress --ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Separating Address Into Individual Columns ( Address, City, State)

select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , len(PropertyAddress)) as City

from NashvilleHousing


Alter table NashvilleHousing
add AddressOfProperty nvarchar(255);

update NashvilleHousing
set AddressOfProperty = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter table NashvilleHousing
add CityOfProperty nvarchar(255);

update NashvilleHousing
set CityOfProperty = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , len(PropertyAddress))

Alter table NashvilleHousing
drop column AdressOfProperty


select *
from NashvilleHousing


select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',', '.'), 3),
PARSENAME(replace(OwnerAddress,',', '.'), 2),
PARSENAME(replace(OwnerAddress,',', '.'), 1)
from NashvilleHousing


Alter table NashvilleHousing
add AddressOfOwner nvarchar(255);

update NashvilleHousing
set AddressOfOwner = PARSENAME(replace(OwnerAddress,',', '.'), 3)

Alter table NashvilleHousing
add CityOfOwner nvarchar(255);

update NashvilleHousing
set CityOfOwner = PARSENAME(replace(OwnerAddress,',', '.'), 2)

Alter table NashvilleHousing
add StateOfOwner nvarchar(255);

update NashvilleHousing
set StateOfOwner = PARSENAME(replace(OwnerAddress,',', '.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,

case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing


-- REMOVE DUPLICATES

with RowNumCTE as(
select *,
row_number() over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num

from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress



-- DELETE UNUSED COLUMN
select *
from NashvilleHousing

ALTER TABLE NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 