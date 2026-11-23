# Question 2: SDTM DS Domain Creation using {sdtm.oak}

Create an SDTM Disposition (DS) domain dataset from raw clinical trial data using the {sdtm.oak}. Develop an R program to create the DS domain using the below criteria.

---

### Conditions for DS Domain

The mock up eCRF that represents the data used includes the programming details, available on the [pharmaverseraw](https://github.com/pharmaverse/pharmaverseraw/blob/main/vignettes/articles/aCRFs/Subject_Disposition_aCRF.pdf) directory. 

In the following, the **"->"** arrow defines as **"mapped to"**. 

**ISO8601 format** to be used: date (YYYY-MM-DD), time (hh:mm:ss)

Criteria:
- ds_raw[IT.DSSTDAT] format DD-MM-YYYY -> ds_domain[DSSTDTC] in ISO8601 format (YYYY-MM-DD)
- if ds_raw[OTHERSP] = not null, then ds_raw[OTHERSP] -> ds_domain[DSDECOD] and ds_domain[DSTERM]
- if ds_raw[OTHERSP] = not null, then ds_domain[DSCAT] = "OTHER EVENT"
- if ds_raw[OTHERSP] = null, then ds_domain[IT.DSDECOD] -> ds_domain[DSDECOD]
- if ds_raw[IT.DSDECOD] = "Randomized", then ds_domain[DSCAT] = "PROTOCOL MILESTONE", else ds_domain[DSCAT] = "DISPOSITION EVENT"
- ds_raw[DSDTCOL] (date: DD-MM-YYYY) + ds_raw[DSTMCOL] (time: HH:MM) -> ds_domain[DSDTC] in ISO8601 format (YYYY-MM-DDThh-mm-ss)

All criteria are additionally documented within the 02_create_ds_domain.R script to highlight each mapping made.

---

### Package structure
```
question_2_sdtm/
├── data/sdtm_ct.csv         #
└── 02_create_ds_domain.R    #
```

---

### Example Usage

All package requirements and steps are outlined within the **02_create_ds_domain.R** script. The intended user just needs to open the script within their own directory with the same data/sdtm_ct.csv structure and the code will run through on its own.

```r
# Input raw data needed
pharmaverseraw::ds_raw

# 02_create_ds_domain.R -> run all code within the script

# Look at DS Domain structure
ds
```
