output close.

GET DATA
  /TYPE=XLS
  /FILE='H:\data_fes\fes_data_20140723.xls'
  /SHEET=name 'FE_Survey'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.


/* Baseline file */
output export 
 /doc DOCUMENTFILE='H:/mbg_it_quality/multi-cnty_fes_feedback/20140726_fes_baseline_LOG.doc'
 /CONTENTS EXPORT=ALL.

/* FE_Survey file */
output export 
 /doc DOCUMENTFILE='H:/mbg_it_quality/multi-cnty_fes_feedback/20140726_fes_FESurvey_LOG.doc'
 /CONTENTS EXPORT=ALL.


SORT CASES BY CountyCode.
SPLIT FILE BY  CountyCode.

/* descriptive statistics and frequencies */
/* for variables in the Family Engagement Study */

/* frequencies for all */

/* any variables for which all answers are don't know or NA? */
/* on Family Conference Survey questions, */
/* don't know is 99 */
/* NA is not in lookup table */
FREQUENCIES VARIABLES=all.


/* descriptives for all */
/* N, Minimum, Maximum, Mean, Std. Deviation */

/* are there any questions for which all answers are the same? */
/* identified via minimum, maximum, and mean being the same */
DESCRIPTIVES VARIABLES=all.


/* anyone where someone responds all 4's or all 1's? */
/* there is a concern that we should not use these responses */

/* start with everyone as "yes" */
/* then change to no if any value is "no" */

COMPUTE allstronglydisagree=1.
COMPUTE allstronglyagree=1.

VARIABLE LABELS allstronglydisagree "All Answers Are Strongly Disagree".
VARIABLE LABELS allstronglyagree "All Answers Are Strongly Agree".

VALUE LABELS allstronglydisagree allstronglyagree 1 'Yes' 0 'No'.

/* loop through all the variable names */
DO REPEAT V#=clear_role TO group_back.
if (V#~=1) allstronglydisagree=0.
if (V#~=4) allstronglyagree=0.
END REPEAT.

/* for FE_Survey */
/* will need to convert all vars from strings to numbers */
/* variable names are Q1 to Q14 */
DO REPEAT V#=Q1 to Q14
 /NEWVAR#=QNUM1 TO QNUM14
 /VALUE#=1 TO 14.
compute NEWVAR#=number(V#, F2.0).
END REPEAT.
execute.

DO REPEAT V#=QNUM1 TO QNUM14.
if (V#~=1) allstronglydisagree=0.
if (V#~=4) allstronglyagree=0.
END REPEAT.



FREQUENCIES VARIABLES=allstronglydisagree allstronglyagree.

SPLIT FILE OFF.