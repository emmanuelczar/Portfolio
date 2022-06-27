-- Data Source : https://finances.worldbank.org/Loans-and-Credits/IBRD-Loans-to-the-Philippines/6aug-xrxs
--World Bank Group Finances
--IBRD (International Bank for Reconstruction and Development) Loans to the Philippines
--Last updated June 15, 2022


--show latest statement of loans worldwide
select *
from PhilippinesLoan.dbo.IBRD_WORLD
order by Country ASC

--show Countries and their loan amount total and obligations
select CountryCode, Country, sum(OriginalPrincipalAmount) as TotalLoanAmount, sum(BorrowersObligation) as TotalObligations
from PhilippinesLoan.dbo.IBRD_WORLD
group by CountryCode, Country
order by TotalLoanAmount DESC





-- shows report from 2011-2022
select *
from PhilippinesLoan.dbo.IBRD_PH2
order by EndofPeriod ASC


--Total Obligations by Date
select EndofPeriod, sum(BorrowersObligation) as HistTotalObligations
from PhilippinesLoan.dbo.IBRD_PH2
where LoanStatus not like '%Cancelled'
group by EndofPeriod
order by EndofPeriod ASC

-- shows all current loans as of May 31 2022 Release excluding cancelled Loans
select *
from PhilippinesLoan.dbo.IBRD_PH2
where EndofPeriod = '2022-05-31' and LoanStatus not like '%Cancelled'

-- show total obligations as of May 31 2022 Release
select Country, sum(BorrowersObligation) as TotalObligations
from PhilippinesLoan.dbo.IBRD_PH2
where EndofPeriod = '2022-05-31'
group by Country

-- shows distribution of borrowers of May 31 2022 Release
select Borrower, sum(OriginalPrincipalAmount) as TotalLoanAmount
from PhilippinesLoan.dbo.IBRD_PH2
where EndofPeriod = '2022-05-31' and LoanStatus not like '%Cancelled'
group by Borrower
order by TotalLoanAmount DESC



--Loan Type Descriptions:
-- B Loan – Co-financing lending product that includes Contingency and Regular loans and guarantees
-- Pool loan- Currency Pooled Loans
-- FSL - Fixed Spread Loans (includes both fixed spread loans and IBRD flexible loans that have either fixed spread or variable spread terms)
-- IFC loan – single currency loans to the IFC
-- Non Pool - Original IBRD lending product, prior to currency pooled loans.
-- Sngl crncy - - Single Currency Loans
-- SCP USD - Single Currency Pooled Loans - USD
-- SCP - DEM - Single Currency Pooled Loans - EUR
-- SCP JPY - Single Currency Pooled Loans – JPY


-- shows types of loan distribution as of May 2022
WITH temporaryTable(TotalLoanAmount) AS
(
select sum(OriginalPrincipalAmount) as TotalLoan0
from PhilippinesLoan.dbo.IBRD_PH2
where EndofPeriod = '2022-05-31' and LoanStatus not like '%Cancelled'
)
	select LoanType, sum(OriginalPrincipalAmount) as LoanAmount, sum(OriginalPrincipalAmount)/temporaryTable.TotalLoanAmount*100 as PercentToBorrowingTotal
	from PhilippinesLoan.dbo.IBRD_PH2, temporaryTable
	where EndofPeriod = '2022-05-31' and LoanStatus not like '%Cancelled'
	group by LoanType, TotalLoanAmount




