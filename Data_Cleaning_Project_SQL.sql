--- View Data ---

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--- Standardize SaleDate ---

SELECT SaleDate, CONVERT (Date,SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate); --- not working this way, make new column

SELECT SaleDate 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;  --- another way to modify datatype in existing column 

SELECT SaleDate 
FROM NashvilleHousing;


--- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL;	 ---there are several null values in PropertyAddress Field

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID;		---we observe that the same parcel ID have the same property address

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;				---display repeated parcel_id rows for Null PropertyAddress field

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]				---fill the null values with the correct PropertyAddress value


---Split PropertyAddress field to its constituents (Address and City)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing;		 ---Splitting the PropertyAddress Field


ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit Nvarchar(255);			---Create separate fields for the constituents

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) ;

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing; 


---Do the same for owner address

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;							---using ParseName function to split the field

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing; 


--- Change Y and N in Sold As Vacant Field

SELECT DISTINCT(Soldasvacant), COUNT(Soldasvacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant							--- Some rows have 'Y'and 'N' instead of 'Yes' or 'No'

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing;		---making the changes for N and Y

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
     ELSE SoldAsVacant
	 END;										---updating the SoldAsVacant field

SELECT DISTINCT(Soldasvacant), COUNT(Soldasvacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant;							---now it contains only 'Yes' or 'No' 


---Remove Duplicates

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID) AS Row_num
FROM PortfolioProject.dbo.NashvilleHousing)	  --- Create a CTE and Assign Row numbers to each row

DELETE 
FROM ROWNUMCTE
WHERE Row_num > 1;								--- Duplicate Rows have Row numbers > 1


--- Delete unwanted Columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress			---Already splitted/correctly formatted columns are generated

