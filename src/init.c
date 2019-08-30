#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP _prepairr_rcpp_prepair(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"_prepairr_rcpp_prepair", (DL_FUNC) &_prepairr_rcpp_prepair, 2},
    {NULL, NULL, 0}
};

void R_init_prepairr(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
