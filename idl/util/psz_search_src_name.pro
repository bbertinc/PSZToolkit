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

FUNCTION psz_search_src_name, cat, names

	;; Index info
	info = size(names)
	dim = info[0]
	type = info[dim+1]

	;; Dimension Check
	if dim GT 1 then begin 
		print, '[Error] <NAMES> arguments has to be of dimension 0 or 1.'
		return, -1
	endif

	;; Type Check
	if type NE 7 then begin
		print, '[Error] <NAMES> arguments has to be of type STRING.'
		return, -1
	endif

	;; Find Matching Sources
	nelts = dim EQ 0 ? 1 : info[1]
	srclist = replicate(cat[0],nelts)
	for i=0, nelts-1 do begin
		idx= WHERE(cat.name EQ names[i], nidx)
		if nidx GT 0 then $
			srclist[i] = cat[idx] $
		else begin
			print, '[Warning] No source with <NAMES> of '+names[i]
			srclist[i].name = -99
		endelse
	endfor

	return, srclist

END