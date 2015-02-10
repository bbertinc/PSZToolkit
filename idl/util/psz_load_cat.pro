;+
; NAME:
;
;   PSZ_LOAD_CAT
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
;   Load and returns a given Planck SZ Database catalog.
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
;   cat = psz_load_cat( [METHOD=method][,VERSION=version][,/UNION] $
; 						[,/SAVE][,/UPDATE][,/VERBOSE])
;
; INPUTS:
;
;   none
;
; KEYWORD PARAMETERS:
;
;   METHOD 		String. Specifies the likelihood calculation method from
; 				which we want to load the result catalog. Options are 'MMF1',
; 				'MMF3', 'PwS' or 'union' (Default='union').
;
;   VERSION 	String. Specifies the version of the catalog. Options are
; 				'R1.11' and 'R1.12'. Depends on <METHOD>.
;
;   UNION 		If set, loads the union catalog with different selected 
; 				method per source.
;
;   SAVE 		If set, writes the catalog in an IDL binary savefile.
;
;   UPDATE 		If set, re-extract the catalog from the .FITS file rather than
; 				from a created IDL binary savefile
;
;   VERBOSE 	Inline feedback.   
;
;
; OUTPUTS:
;
;   cat 	Structure. List of 2D likelihood arrays with metadata for each source
; 			in the Planck SZ database.
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
;   2015-01-15   B. Bertincourt   written
;-

FUNCTION psz_load_cat, METHOD=method, VERSION=version, UNION=union, $
			SAVE=sav, UPDATE=upd, VERBOSE=ver

	;; Load Project Info
	info = psz_info()

	;; Method
	if ~KEYWORD_SET(method) then method = 'union'
	if ~KEYWORD_SET(version) then begin
		if method EQ 'MMF3' or method EQ 'union' then $
			version = 'R1.12' $
		else $
			version = 'R1.11'
	endif

	filename = 'COM_PCCS_SZ-'+method+'_'+version

	if ~FILE_TEST(info.path_save+filename+'.save') OR KEYWORD_SET(upd) then begin

		if method EQ 'union' then begin

			;; Load Planck SZ Union Catalog FITS File
			table_union = mrdfits(info.path_data+filename+'.fits',1,t_hdr)

			;; Load Individual catalogs
			cat_MMF1 = psz_load_cat(method='MMF1', version='R1.11')
			cat_MMF3 = psz_load_cat(method='MMF3', version='R1.12')
			cat_PwS = psz_load_cat(method='PwS', version='R1.11')

			;; Catalog structure
			nsrc = (size(table_union))[1]
			cat = replicate(cat_MMF1[0],nsrc)

			for i=0, nsrc-1 do begin
				index = table_union[i].index
				case table_union[i].pipeline of
					1: src = cat_MMF1[where(cat_MMF1.index EQ index)]
					2: src = cat_MMF3[where(cat_MMF3.index EQ index)]
					3: src = cat_PwS[where(cat_PwS.index EQ index)]
				endcase
				if KEYWORD_SET(debug) then $
					print, "[Debug] Source ID: "+src.name+" / Index "+strtrim(src.index,2)
				cat[i] = src
			endfor

		endif else begin

			;; Load Planck SZ Catalog FITS File
			table = mrdfits(info.path_data+filename+'.fits',1,t_hdr)
			data = mrdfits(info.path_data+filename+'.fits',2,d_hdr)

			nsrc = (size(table))[1]

			;; Catalog Structure
			cat_info = {name: filename, $
						method: method, $
						version: version $
						}

			entry = {index: 0, name: '', glon: 0.d, glat: 0.d, ra: 0.d, dec: 0.d, $
					 pos_err: 0., snr: 0., snr_compat:0., $
					 ts_min: 0., ts_max: 0., $
					 y_min: 0., y_max: 0., $
					 ;units: {}, $
					 info_: ptr_new(), $
					 probability: fltarr(256,256) $
					 }

			cat = replicate(entry,nsrc)

			struct_assign, table, cat
			cat.info_ = ptr_new(cat_info)
			cat.probability = transpose(data,[1,0,2])

		endelse

		;; SAVE
		if KEYWORD_SET(sav) then begin
			save, filename=info.path_save+filename+'.save', cat
		endif

	endif else begin
		;; RESTORING
		restore, info.path_save+filename+'.save'

	endelse

	return, cat

END