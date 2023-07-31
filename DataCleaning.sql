
--CLEANING DATA IN SQL QUERIES

select *
from PortfolioProject..NashvilleHousing


--STANDARDIZE DATE FORMAT

select SaleDateConverted, convert (date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert (date, SaleDate) --didnt work

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert (date, SaleDate)


--POPULATE PROPERTY ADDRESS DATA

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

from PortfolioProject..NashvilleHousing

--create 2 more columns to insert the datas from above query

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);
update NashvilleHousing
set  PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);
update NashvilleHousing
set  PropertySplitCity =  SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

-------

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME (Replace (OwnerAddress,',','.'), 3)
,PARSENAME (Replace (OwnerAddress,',','.'), 2)
, PARSENAME (Replace (OwnerAddress,',','.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar (255);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME (Replace (OwnerAddress,',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar (255);
update NashvilleHousing
set OwnerSplitCity = PARSENAME (Replace (OwnerAddress,',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar (255);
update NashvilleHousing
set OwnerSplitState = PARSENAME (Replace (OwnerAddress,',','.'), 1)


--CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN "SOLID AS VACANT" FIELD

select distinct (SoldAsVacant), count (SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing



--REMOVE DUPLICATES

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by    ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID
						) row_num
from PortfolioProject..NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--DELETE UNUSED COLUMNS

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate