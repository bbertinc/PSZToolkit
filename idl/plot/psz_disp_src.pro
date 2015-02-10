;+
; NAME:
;
;   PSZ_DISP_SRC
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
;   Display a graphics representation of the 2D likelihood of a given
;   Planck SZ catalog entry.
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
;   psz_disp_src, src [, Estimate=estimate [,/CONTOURS][,/RIDGE]][,WINDOW=win]
;				 [,LOADCT=lct][,_EXTRA=extra]
;
; INPUTS:
;
;   src 	Structure. A single Planck SZ catalog entry.
;
; KEYWORD PARAMETERS:
;
;   ESTIMATE 	Structure. As obtained using the psz_estimate.pro function.
;				E.g:  estimate = psz_estimate(src)
;
;   CONTOURS 	If set, adds contours to the 2D likelihood display provided
;				they are present in the estimate structure.
;
;   RIDGE 		If set, adds ridge location to the 2D likelihood display provided
; 				it has been calculated and is present in the estimate structure.
;
;   WINDOW 		Integer. Specifies the window index for the figure to be displayed
;				into.
;
;   LOADCT 		Integer. Specifies the color table to be used (Default=39).
;
;
; OUTPUTS:
;
;   none
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
;   2015-01-15   B. Bertincourt   written
;-

PRO psz_disp_src, src, ESTIMATE=estimate, CONTOURS=contours, RIDGE=ridge, WINDOW=win, LOADCT=lct, $
		_EXTRA=extra

	;; KEYWORDS	
	if ~KEYWORD_SET(lct) then lct = 39
	if KEYWORD_SET(win) then $
		window, win, XSIZE=700, YSIZE=700 $
	else window, XSIZE=700, YSIZE=700

	!p.charsize = 1.5
	loadct, lct

	!p.position = [0.15,0.15,0.85,0.85]
	imdisp, src.probability, /AXIS, out_pos = out_pos, /erase, xsty=13, ysty=13, title=src.name

	axis, xaxis=0, xrange=[src.ts_min, src.ts_max], /xsty, xtitle='!4h!3 [arcmin]'
	axis, yaxis=0, yrange=[src.y_min, src.y_max], /ysty, ytitle='Y [arcmin !E2!N]'
	axis, xaxis=1, xrange=[src.ts_min, src.ts_max], /xsty, xcharsize=0.01
	axis, yaxis=1, yrange=[src.y_min, src.y_max], /ysty, ycharsize=0.01

	;; ESTIMATIONS
	if KEYWORD_SET(estimate) then begin
		if KEYWORD_SET(contours) then $
			contour, src.probability, LEVELS=reverse(estimate.contours.value), position = out_pos, $
				/noerase, /follow, xsty=13, ysty=13, _EXTRA=extra

		if KEYWORD_SET(ridge) then begin
			plot, /noerase, estimate.ridge.ts, estimate.ridge.y, position = out_pos, $
				xrange=[src.ts_min,src.ts_max], yrange=[src.y_min,src.y_max], $
				xsty=5, ysty=5, LINE=3, _EXTRA=extra
			oplot, estimate.ridge.ts, estimate.ridge.y+estimate.ridge.y_err[0], LINE=1
			oplot, estimate.ridge.ts, estimate.ridge.y+estimate.ridge.y_err[1], LINE=1
		endif
	endif

	!p.charsize = 1.
	!p.position = 0

END