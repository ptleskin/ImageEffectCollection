#	Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 


#	Color tables:
#	effect45_colors.png: 
#		3-color palette as in example
colortable="effect14_colortable.png"


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`

#	parameters for pattern, integers:
tilesize=5
tileangle=0 # or maybe 45

#	0=maps the pattern colors from black'n'white, 100 from image's colors:
saturation=10


# Add midtones. lower contrast:
# 3rd degree low-sigma -function polynomial 4,-6,3,0
lowSigma3='4,-6,3,0'
# 5th degree low-sigma -function polynomial 16,-40,40,-20,5,0
lowSigma5='16,-40,40,-20,5,0'

# random remarks:
# Add contrast:
# high-Sigma, -function polynomial $hiSigmaN 
hiSigma3='-2,3,0,0'
hiSigma5='6,-15,10,0,0,0'
hiSigma7='-20,70,-84,35,0,0,0,0'
hiSigma9='70,-315,540,-420,126,0,0,0,0,0'



convert \( -size $((tilesize))x$((tilesize)) \
		xc:white \
		-virtual-pixel black \
		-blur 0x$((tilesize/2)) -auto-level \
		-write mpr:tile +delete \
	\) \
	\( $infile -unsharp 0x3 \
		\( tile:mpr:tile -set option:distort:viewport ${size}+0+0 \
		-virtual-pixel tile -filter point -distort SRT 1,$tileangle \
		\) \
		-compose dissolve -define compose:args='75,25' \
		-modulate 100,$saturation \
	\) \
	\( $infile -colorspace Gray \
		\( +clone -blur 0x1 -negate \) \
		-compose Overlay -composite \
		-equalize -level 5%,95% \
		-function polynomial $lowSigma3 \
	\) \
	-compose Overlay -composite \
	-level 20%,70% $colortable -clut \
	-dither None -remap $colortable \
	$outfile
