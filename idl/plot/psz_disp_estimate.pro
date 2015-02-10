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

PRO psz_disp_estimate, estimates, ERROR=err, LOGARITHMIC=log, WINDOW=win

	;; Set
	nsrc = (size(estimates))[1]
	if nsrc LT 2 then begin
		print, '[Error] Not enough data points.'
	endif

	;; Ranges
	if KEYWORD_SET(log) then begin
		idx = WHERE(estimates.ts.value GT 0 and estimates.y.value GT 0)
		xr = 10^(minmax(alog10(estimates[idx].ts.value))) * [0.5,2]
		yr = 10^(minmax(alog10(estimates[idx].y.value))) * [0.5,2]
	endif else begin
		xr = minmax(estimates.ts.value) * [0.8,1.2] 
		yr = minmax(estimates.y.value) * [0.8,1.2]
	endelse


	;; DISPLAY
	if KEYWORD_SET(win) then window, win else window

	!p.charsize=1.5

	loadct, 39
	plotsym, 0, 1, /FILL

	if KEYWORD_SET(err) then begin
		loadct, 0
		ploterror, estimates.ts.value, estimates.y.value, estimates.ts.error[1], $
			estimates.y.error[1], PSYM=8, ERRTHICK=0.5, ERRCOLOR=150, COLOR=255, $
			xrange=xr, yrange=yr, /XSTY, /YSTY, XLOG=log, YLOG=log, $
			xtitle='!4h!3 [arcmin]', ytitle='Y [arcmin!E2!N]'
		oplot, estimates.ts.value, estimates.y.value, PSYM=8
		loadct, 39
	endif else begin
		plot, estimates.ts.value, estimates.y.value, PSYM=8, XLOG=log, YLOG=log, $
		xrange=xr, yrange=yr, /XSTY, /YSTY, $
		xtitle='!4h!3 [arcmin]', ytitle='Y [arcmin!E2!N]'
	endelse

	!p.charsize=1

END