;+
; NAME:
;
;   PSZ_ESTIMATE
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
;   Computes and returns SZ properties estimates and statistics for a list of sources
;   in the Planck SZ catalog.
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
;   estimate = psz_estimate(srclist [,/CONTOURS][,/RIDGE][,/STATISTICS][,/DEBUG])
;
; INPUTS:
;
;   srclist 	Structure array. List of Planck SZ catalog entries.
;				E.g: > cat = psz_load_cat()
; 				     > srclist = cat[0:10]
;
; KEYWORD PARAMETERS:
;
;   CONTOURS 	If sets, calculates the 2D likelihood contour value at 68, 95 and 99%
;
;   RIDGE 		If sets, estimates the maximum and uncertainties of the marginalized
; 				probability density functions at each value of theta.
;
;   STATISTICS 	If sets, stores the probability density functions and cumulative 
; 				distribution functions marginalized on theta and Y.
;
;   DEBUG 		If sets, run in debug mode with inline feedback.
;
;
; OUTPUTS:
;
;   estimate 	Structure. Contains the theta max and Y max with assymetric errors 
; 				estimated from the 2D likelihood array.
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
;   2015-01-15   B. Bertincourt   written
;-

FUNCTION psz_estimate, srclist, CONTOURS=contours, RIDGE=ridge, STATISTICS=stats, $
		DEBUG=debug

	;; Analyse SRCLIST
	info = size(srclist)
	nsrcs = info[1]

	npts = (size(srclist[0].probability))[1]

	;; Constants
	sigmas = erf( (indgen(3)+1.) / sqrt(2.) )

	;; Estimate Structure
	estimate = {src_: ptr_new(), $
				content: {contours:0,ridge:0,statistics:0}, $
				ts: {value: 0.d, error: dblarr(2), unit: 'arcmin'}, $
				y: {value: 0.d, error: dblarr(2), unit: 'arcmin!E2!N'}, $
				contours: {sigma: sigmas, value: dblarr(3)}, $
				ridge: replicate({ts: 0., y: 0., y_err: [0.,0.]}, npts), $
				statistics: {ts: {pdf: dblarr(npts), cdf: dblarr(npts)}, $
							 y: {pdf: dblarr(npts), cdf: dblarr(npts)} $
			 				} $
				}

	estimate.content.contours = KEYWORD_SET(contours)
	estimate.content.ridge = KEYWORD_SET(ridge)
	estimate.content.statistics = KEYWORD_SET(stats)

	estimates = replicate(estimate,nsrcs)

	for isrc=0,nsrcs-1 do begin

		src = srclist[isrc]
		estimates[isrc].src_ = ptr_new(src)

		;; Source Likelihood Axes
		axes = psz_axes(src)

		;; Find Max
		proba_max = max(src.probability, index_max)

		estimates[isrc].ts.value = (1 - (index_max mod 256) / 255.) * src.ts_min + $
			((index_max mod 256) / 255.) * src.ts_max
		estimates[isrc].y.value = (1 - (index_max / 256) / 255.) * src.y_min + $
			((index_max / 256) / 255.) * src.y_max

		;; Compute Probability Density Functions
		ts_pdf = dblarr(npts)
		y_pdf = dblarr(npts)

		for i=0,255 do begin
			ts_pdf[i] = int_tabulated(findgen(npts), src.probability[i,*])
			y_pdf[i]  = int_tabulated(findgen(npts), src.probability[*,i])
		endfor

		if KEYWORD_SET(stats) then begin
			;; Store the Marginalized probability density
			;; Functions in the result structure
			estimates[isrc].statistics.ts.pdf = ts_pdf
			estimates[isrc].statistics.y.pdf = y_pdf
		endif 

		;; Compute Cumulative Distribution Function
		proba_ord = sort(src.probability)
		ts_ord = sort(ts_pdf)
		y_ord = sort(y_pdf)

		cdf = total( src.probability[proba_ord], /CUMULATIVE)
		ts_cdf = total( ts_pdf[ts_ord], /CUMULATIVE )
		y_cdf = total( y_pdf[y_ord], /CUMULATIVE )

		if KEYWORD_SET(stats) then begin
			;; Store the Marginalized cumulative distribution
			;; Functions in the result structure
			estimates[isrc].statistics.ts.cdf = ts_cdf
			estimates[isrc].statistics.y.cdf = y_cdf
		endif

		;; Find 68-95-99 % cutoffs
		ts_pdf_sorted = ts_pdf[ts_ord]
		y_pdf_sorted = y_pdf[y_ord]

		ts_icuts = INTERPOL(findgen(npts), ts_cdf, 1 - sigmas)
		y_icuts = INTERPOL(findgen(npts), y_cdf, 1 - sigmas)

		ts_cuts = INTERPOL(ts_pdf_sorted, findgen(npts), ts_icuts)
		y_cuts = INTERPOL(y_pdf_sorted, findgen(npts), y_icuts)

		if KEYWORD_SET(contours) then begin
			pdf_sorted = src.probability[proba_ord]
			pdf_icuts = INTERPOL(findgen(1L*npts*npts), cdf, 1 - sigmas)
			estimates[isrc].contours.value = INTERPOL(pdf_sorted, findgen(1L*npts*npts), pdf_icuts)
		endif

		;; Compute 68-95-99 interval boundaries [TODO: Flags/Log the saturation cases]
		if KEYWORD_SET(debug) then $
			print, FORMAT='(%"[Debug][Boundaries] Source Index %i")', src.index

		ts_max = max(ts_pdf, ts_imax)
		if ts_imax GT 5 then $  
			ts_left_bounds = INTERPOL(axes.ts[0:ts_imax],ts_pdf[0:ts_imax],ts_cuts) $
		else $ ;; Not enough points to get a left bound
			ts_left_bounds = axes.ts[0]
		if ts_imax LT npts-5 then $
			ts_right_bounds = INTERPOL(axes.ts[ts_imax:*],ts_pdf[ts_imax:*],ts_cuts) $
		else $
			ts_right_bounds = axes.ts[npts-1]

		y_max = max(y_pdf, y_imax)
		if y_imax GT 5 then $
			y_left_bounds = INTERPOL(axes.y[0:y_imax],y_pdf[0:y_imax],y_cuts) $
		else $
			y_left_bounds = axes.y[0]
		if y_imax LT npts-5 then $
			y_right_bounds = INTERPOL(axes.y[y_imax:*],y_pdf[y_imax:*],y_cuts) $
		else $
			y_right_bounds = axes.y[npts-1]

		estimates[isrc].ts.error = [ts_left_bounds[0],ts_right_bounds[0]] - estimates[isrc].ts.value
		estimates[isrc].y.error = [y_left_bounds[0],y_right_bounds[0]] - estimates[isrc].y.value

		;; Compute Ridge
		if KEYWORD_SET(ridge) then begin

			if KEYWORD_SET(debug) then $
				print, FORMAT='(%"[Debug][Ridge] Source Index %i")', src.index

			estimates[isrc].ridge.ts = axes.ts

			for i=0,npts-1 do begin

				p_pdf = src.probability[i,*] / INT_TABULATED(findgen(npts),src.probability[i,*])
				pmax = max(src.probability[i,*], ipmax)
				estimates[isrc].ridge[i].y = axes.y[ipmax]

				p_ord = sort(p_pdf)
				p_cdf = total(p_pdf[p_ord], /CUMULATIVE)
				p_icuts = INTERPOL(findgen(npts), p_cdf, 1 - sigmas)
				p_cuts = INTERPOL(p_pdf[p_ord], findgen(npts), p_icuts)
				p_left_bounds = INTERPOL(axes.y[0:ipmax],p_pdf[0:ipmax], p_cuts)
				if ipmax LT npts-5 then $
					p_right_bounds = INTERPOL(axes.y[ipmax:*],p_pdf[ipmax:*], p_cuts) $
				else $
					p_right_bounds = axes.y[ipmax] + (axes.y[ipmax] - p_left_bounds)

				estimates[isrc].ridge[i].y_err = [p_left_bounds[0],p_right_bounds[0]] - estimates[isrc].ridge[i].y
			endfor

		endif

	endfor

	return, estimates

END