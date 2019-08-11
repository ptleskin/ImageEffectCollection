#	Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 

#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`

#	Output lightness:
lightness='1.5'

#	Cell size:
cellsize="9"

#	size for an image pixel cells:
w2=`convert $infile -format %w/$cellsize info:`
h2=`convert $infile -format %h/$cellsize info:`


convert \( -size 1x1 xc:"#000" \) \( -size 1x1 xc:"#FFF" \) +append \
	\( \( -size 1x1 xc:"#FFF" \) \( -size 1x1 xc:"#000" \) +append \) \
	-append \
	-write mpr:chesscell -delete 0 \
	\
	\
	$infile \
	-filter Box -resize "$((w2))x$((h2))!" \
	-virtual-pixel mirror \
	-convolve "0 -1 0 -1 9 -1 0 -1 0" \
	-filter Point -resize "${size}!" \
	-gamma $lightness \
	\
	\
	\( -size "$((w2))x$((h2))" tile:mpr:chesscell \
		-filter Point -resize "${size}!" \
		-convolve "1,1,1  1,12,1  1,1,1" \
		-function polynomial 4,-4,1.2 \
		-blur 1.3x0.5 -function polynomial 0.5,0.5 \
	\) -compose Multiply -composite \
	\
	\
	-morphology Convolve \
            "3x7:  \
		0,0.1,0  \
		0,0.3,0  \
		0.3,0.5,0.3  \
		0,1,0  \
		-0.3,-0.5,-0.3  \
		0,-0.3,0 \
		0,-0.1,0 \
		" \
	-convolve "0 -1 0 -1 8 -1 0 -1 0" \
	$outfile
