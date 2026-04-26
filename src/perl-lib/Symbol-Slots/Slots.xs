#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = Symbol::Slots  PACKAGE = Symbol::Slots
PROTOTYPES: ENABLE

SV*
slots(SV* glob_sv)
    CODE:
    {
        GV* gv;
        if (SvTYPE(glob_sv) == SVt_PVGV) {
            gv = (GV*)glob_sv;
        } else if (SvROK(glob_sv) && SvTYPE(SvRV(glob_sv)) == SVt_PVGV) {
            gv = (GV*)SvRV(glob_sv);
        } else {
            croak("not a glob");
        }
        HV* hv = newHV();
        struct gp* gp = GvGP(gv);
        if (gp->gp_sv) hv_stores(hv, "SCALAR", newSViv(1));
        if (gp->gp_av) hv_stores(hv, "ARRAY",  newSViv(1));
        if (gp->gp_hv) hv_stores(hv, "HASH",   newSViv(1));
        if (GvCV(gv))  hv_stores(hv, "CODE",   newSViv(1));
        if (GvIO(gv))  hv_stores(hv, "IO",     newSViv(1));
        RETVAL = newRV_noinc((SV*)hv);
    }
    OUTPUT:
        RETVAL

