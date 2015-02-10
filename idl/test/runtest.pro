
PATH_DATA = EXPAND_PATH('$HOME/plancksz/data/')+'/'

filelist = file_search(path_data+'*.fits')

table = mrdfits(filelist[0],1,hd1)
data = mrdfits(filelist[0],2,hd2)

sz = size(data[*,*,0])

;; Parameter range and step
print, (table[0].ts_max - table[0].ts_min) / sz[1]
print, (table[0].y_max - table[0].y_min) / sz[2]

;; Example Plot 1
plotsym, 0, 1, /FILL 
plot, table.ra, table.dec, PSYM=8, xrange=[0,360], /xsty, xtitle='RA', ytitle='DEC'

;; Example Plot 2
loadct, 39
imdisp, data[*,*,0], /AXIS, out_pos = out_pos, /erase
;axis, XAXIS=0, xrange=[], xtitle='!4r!3!LS!N'
;axis, YAXIS=0, xrange=[], ytitle='Y'
contour, data[*,*,0], /noerase, position = out_pos, NLEVELS=16, xsty=13, ysty=13, /follow
