#
#	Image Effect
#	Espoo, Finland, October 2012
#	Petri Leskinen, petri.leskinen@aalto.fi
#	


#	Locations of input and output images:
infile=$1 
outfile=$2 


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


# number of color shades
numColors="64"


# amount of dark parts in image, gamma value, 0.4:dark 1:normal, 2.5:light
dark="0.4"




convert $infile -auto-level \
	-virtual-pixel edge \
	\( -clone 0 -selective-blur 12x4 \
		-dither Riemersma -colors $numColors -paint 2 \
		\( +clone -resize 4% -modulate 100,0 \
			-negate -resize "${size}!" \) \
		-compose Overlay -composite \
		\
		\( +clone -modulate 100,0 -edge 1 \
			-function polynomial 0.25,0 \) \
		-compose MinusSrc -composite \
		\
		\( -size "${size}" xc:"#BBB" -random-threshold 10%,90% \
			-convolve "0 1 0  1 6 1  0 1 0" \
		\) \
		-alpha off -compose Copy_Opacity -composite \
		\) \
	\( +clone -channel RGB -function polynomial 0.8,0,0 \
		-channel A -distort SRT "1,0 1,1 0 0,0" -channel RGBA \) \
	+swap \
	-compose Over -flatten \
	$outfile

