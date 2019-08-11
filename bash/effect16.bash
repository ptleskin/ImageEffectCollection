#	Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


blurAmount=60

brightness=115
saturation=94
hue=0

convert $infile \
	\
	-channel R \
	  -function polynomial 0.6881,0,0.3119,0 	\
	-channel G \
	  -function polynomial 0.3789,-0.724,1.3451,0 	\
	-channel B \
	  -function polynomial -0.3966,1.3966,0 	\
	\
	-channel RGB \
	 -function polynomial 1.5549,-0.1585	\
 	 -function polynomial 0.7412,0.0118 	\
	\
	\( +clone \
		-resize 100%,5% 	\
		-virtual-pixel mirror 	\
		-morphology Convolve "1x10: 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1" \
		-morphology Convolve "1x10: 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1" \
		-morphology Convolve "1x10: 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1" \
		-morphology Convolve "1x10: 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1" \
		-morphology Convolve "1x10: 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1" \
		-modulate $brightness,$saturation,$hue \
		-resize "${size}!" 	\
	\) \
	\
	-compose blend -define compose:args=$blurAmount -composite \
	-gamma 1.4 \
	\
	$outfile



