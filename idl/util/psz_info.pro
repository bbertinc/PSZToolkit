;+
; NAME:
;
;   PSZ_INFO
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
;   Returns a structure containing session infos and paths.
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
;   info = psz_info()
;
; INPUTS:
;
;   none
;
; KEYWORD PARAMETERS:
;
;   none
;
; OUTPUTS:
;
;   info 	Structure. Planck SZ toolkit work session information.
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
;   2015-01-15   B. Bertincourt   written
;-

FUNCTION psz_info

	MAIN_PROJET_PATH = EXPAND_PATH(!IPJ_CURRENT)+'/'

	info = {name:'plancksz', $
			short: 'psz', $
			path: MAIN_PROJET_PATH, $
			path_data: MAIN_PROJET_PATH+'data/', $
			path_save: MAIN_PROJET_PATH+'save/', $
			path_plots: MAIN_PROJET_PATH+'plots/' $
			}

	return, info

END
