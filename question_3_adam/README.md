# Question 3: ADaM ADSL Dataset Creation

Develop an R program to create the ADSL using the input SDTM data, the {admiral} family of packages, and tidyverse tools. 

This additional variable derivation is very similar to the ADSL example in the [Pharmaverse ADSL Example](https://pharmaverse.github.io/admiral/cran-release/articles/adsl.html) : ADSL, which was used as a primary reference for code creation. 

---

### Conditions for ADSL Creation

The DM domain is used as the basis of the ADSL. The pharmaversesdtm::dm was first assigned to a an adsl object as explained in the abovementioned ADSL example. 

**admiral** functions were used as a primary source for variable derivation, and are appropriately noted within the R script.

The following criteria were used in deriving the required ADSL documents:
```{bash}
AGER9 (Age grouping): "<18" "18-50" ">50"
AGER9N (Age grouping): 1, 2, 3

TRTSDTM (Treatment Start Time):
	- Set to datetime of patient's first exposure treatment start (EX.EXSTDTC)
	- If time is missing, impute to 00:00:00
	- If time is partially missing, impute with 00 in the missing hours, minutes, or seconds sections.
	- If only seconds are missing do not populate the imputation flag.

ITTFL (Identifying randomized patients):
	- ARM will be populated from pharmaversesdtm::dm domain.
	- Set to "Y" if DM.ARM not equal to missing
	- Set to "N" if DM.ARM missing 
	 
ABNSBPFL (Identifying patients with a supine systolic blood pressure <100 or >=140 mmHg):
	- Set to "Y" if: VS.VSTESTCD = "SYSBP" + VS.VSSTRESU = "mmHg" + VS.VSSTRESN >= 140 or <100
	- Set to "N" if all three conditions do not fit

LSTALVDT (Last known alive date):
	Uses: any vital signs date, adverse event start date, disposition record, and exposure record
	Extract the following:
	- Last complete date of vital assessment: VS.VSSTRESN not null + VS.VSSTRESC not null + VS.VSDTC datepart not missing
	- Last complete onset date of AEs: last datepart of AE.AESTDTC
	- Last complete disposition date: last datepart of DS.DSSTDTC
	- Last date of treatment administration: datepart of ADSL.TDTEDTM
	Value set to max date of the above criteria. 

CARPOPFL (Identifying patients with a cardiac adverse event):
	- Set to "Y" if uppercase AE.AESOC = "CARDIAC DISORDERS"
	- Set to missing if not the above
```

All criteria are additionally documented within the **create_adsl.R** script to highlight each derivation made.

---

### Package structure
```
question_3_adam/
└── create_adsl.R    # R Script for ADSL creation
```

---

### Example Usage

All package requirements and steps are outlined within the **create_adsl.R** script. The intended user just needs to open the script within their own directory and the code will run through on its own.

```r
# Input SDTM data needed
dm <- pharmaversesdtm::dm
vs <- pharmaversesdtm::vs
ex <- pharmaversesdtm::ex
ds <- pharmaversesdtm::ds
ae <- pharmaversesdtm::ae

# create_adsl.R -> run all code within the script

# Look at final ADSL Domain structure
adsl
```
