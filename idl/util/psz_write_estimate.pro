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

PRO psz_write_estimate, estimates, FILENAME=filen, SAVE=save, OVERWRITE=overwrite, $
		CONTOURS=contours, RIDGE=ridge, MARGINALIZED_STATISTICS=mstats

	;; Load Project Info
	info = psz_info()

	;; Filename
	finfo = size(filen)
	if finfo[2] EQ 0 then begin
		filen = "psz_temp_estimate"
	endif

	;; Save Option
	if KEYWORD_SET(sav) then begin
		save, filename=info.path_save+filen+'.save', estimates
	endif

	;; WRITING ESTIMATES TO FITS
	;; Flattening structures
	nsrc = (size(estimates))[1]
	basic = {srcname:"",$
			 index: 0, $
			 ts_max:0.d, ts_err1:0.d, ts_err2:0.d,$
			 y_max:0.d, y_err1:0.d, y_err2:0.d $
			 }
	basics = replicate(basic, nsrc)

	basics.ts_max = estimates.ts.value
	basics.ts_err1 = estimates.ts.error[0]
	basics.ts_err2 = estimates.ts.error[1]

	basics.y_max = estimates.y.value
	basics.y_err1 = estimates.y.error[0]
	basics.y_err2 = estimates.y.error[1]

	for i=0,nsrc-1 do begin
		basics[i].srcname = (*estimates[i].src_).name
		basics[i].index = (*estimates[i].src_).index
	endfor

	fxbhmake, basics_hdr, nsrc, "PSZ_ESTIMATES"

	fxaddpar, basics_hdr, "TUNIT1", "None"
	fxaddpar, basics_hdr, "TUNIT2", "None"
	fxaddpar, basics_hdr, "TUNIT3", "arcmin"
	fxaddpar, basics_hdr, "TUNIT4", "arcmin"
	fxaddpar, basics_hdr, "TUNIT5", "arcmin"
	fxaddpar, basics_hdr, "TUNIT6", "arcmin^2"
	fxaddpar, basics_hdr, "TUNIT7", "arcmin^2"
	fxaddpar, basics_hdr, "TUNIT8", "arcmin^2"

	mwrfits, basics, info.path_save+filen+'.fits', basics_hdr

	;; CONTOURS
	if KEYWORD_SET(contours) then begin
		if estimates[0].content.contours then begin
			entry = {srcname:"",index:0,c68:0.d,c95:0.d,c99:0.d}
			f_contours = replicate(entry, nsrc)

			f_contours.srcname = basics.srcname
			f_contours.index = basics.index
			f_contours.c68 = estimates.contours.value[0]
			f_contours.c95 = estimates.contours.value[1]
			f_contours.c99 = estimates.contours.value[2]

			fxbhmake, contours_hdr, nsrc, EXTNAME="PSZ_CONTOURS"

			fxaddpar, basics_hdr, "TUNIT1", "None"
			fxaddpar, basics_hdr, "TUNIT2", "None"
			fxaddpar, basics_hdr, "TUNIT3", "None"
			fxaddpar, basics_hdr, "TUNIT4", "None"
			fxaddpar, basics_hdr, "TUNIT5", "None"

		endif else begin
			print, "[Warning] No <CONTOURS> in structure <ESTIMATES>. Ignoring keyword."
		endelse
	endif

	;; RIDGE
	if KEYWORD_SET(ridge) then begin
		if estimates[0].content.ridge then begin
			entry = {srcname:""}
			f_ridge = replicate(entry, nsrc)
		endif else begin
			print, "[Warning] No <RIDGE> in structure <ESTIMATES>. Ignoring keyword."
		endelse
	endif

	;; MARGINALIZED DISTRIBUTIONS
	if KEYWORD_SET(mstats) then begin
		if estimates[0].content.statistics then begin
			entry = {srcname:""}
			f_mstats = replicate(entry, nsrc)
		endif else begin
			print, "[Warning] No <STATISTICS> in structure <ESTIMATES>. Ignoring keyword."
		endelse
	endif


END