;+
; NAME:
;
;   PSZ_INIT
;
; VERSION:
;
;   1.0 (Jan. 2015)
;
; PURPOSE:
;
;   Sets the Planck SZ database toolkit working directory for
;   the current session.
;
; REFERENCE:
;
; CATEGORY:
;
;   Planck SZ Database Toolkit [PSZkit]
;
; CALLING SEQUENCE:
;
;   psz_init [,DIRECTORY=dirname]
;
; INPUTS:
;
;   none
;
; KEYWORD PARAMETERS:
;
;   DIRECTORY 	String. Specifies the directory in which the 'pro/' IDL toolkit
; 				code directory can be found (Default=$PWD)
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
;   Copyright (C) 2015 - Benjamin Bertincourt
;
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program.  If not, see <http://www.gnu.org/licenses/>.
;-

PRO psz_init, DIRECTORY=dirname

	d_info = size(dirname)
	if d_info[2] EQ 0 then begin
		cd, current=dirname 
	endif

	len = strlen(dirname)
	if strmid(dirname,len-1) NE '/' then dirname += '/'

	defsysv, '!IPJ_CURRENT', dirname
	!PATH = !PATH + ':' + EXPAND_PATH('+'+!IPJ_CURRENT+'pro/')

END