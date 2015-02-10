;+
; NAME:
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
;   2015-01-15   B. Bertincourt   written
;-

FUNCTION psz_search_src, query, CATALOG=cat, METHOD=method, VERSION=version

	;; Load Catalog
	isCatDefined = size(cat,/TYPE)
	if isCatDefined EQ 0 then begin
		cat = psz_load_cat(METHOD=method, VERSION=version)
	endif

	;; Analyse Query
	qinfo = size(query)
	qdim = qinfo[0]
	qtype = qinfo[qdim+1]

	case qtype of
		2: srclist = psz_search_src_index(cat, query)
		3: srclist = psz_search_src_index(cat, query)
		7: srclist = psz_search_src_names(cat, query)
		8: srclist = psz_search_src_pos(cat, query)
	endcase

	return, srclist

END