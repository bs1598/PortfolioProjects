/*
------DATA CLEANING-------

Cleaning up the HousingData using SQL

*/

select * from Housingdata

--Standardizing the sale date

select SaleDate2, cast(SaleDate as date) from Housingdata

alter table HousingData
add SaleDate2 Date;

update Housingdata
Set SaleDate2 = cast(SaleDate as date)


-------------------------------------------------------------------------------------

---Populate Property Address Data

select *
from Housingdata
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Housingdata a
join Housingdata b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Housingdata a
join Housingdata b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------
--Separating Address into Individual Columns( Address, City, State)

select PropertyAddress
from Housingdata
--where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)  as PropertySplitAddress,
substring(PropertyAddress, charindex(',',PropertyAddress)+1,Len(PropertyAddress))  as PropertySplitCity
from Housingdata

alter table HousingData
add PropertySplitAddress Nvarchar(255) ;

update Housingdata
Set PropertySplitAddress = substring(PropertyAddress,1, charindex(',',PropertyAddress)-1)

alter table HousingData
add PropertySplitCity Nvarchar(255) ;

update Housingdata
Set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress)+1,Len(PropertyAddress)) 

---Doing the same for OwnerAddress using PARSENAME

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from Housingdata

alter table HousingData
add OwnerSplitAddress Nvarchar(255) ;

update Housingdata
Set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

alter table HousingData
add OwnerSplitCity Nvarchar(255) ;

update Housingdata
Set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

alter table HousingData
add OwnerSplitState Nvarchar(255) ;

update Housingdata
Set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);

----------------------------------------------------------------------------------

--- Change Y and N to Yes and No in  "Sold as Vacant" field

Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end
from Housingdata

update housingdata
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end 

--------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housingdata
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From Housingdata


------------------------------------------------------------------------------------
--Delete unused columns

Select *
From Housingdata


ALTER TABLE Housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
