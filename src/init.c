#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP _rppreiar_rcpp_prepair(SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"_rppreiar_rcpp_prepair", (DL_FUNC) &_rppreiar_rcpp_prepair, 1},
    {NULL, NULL, 0}
};

void R_init_rppreiar(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
