
#	Image Effect
#	Espoo, Finland, September 2012
#	Petri Leskinen, petri.leskinen@aalto.fi

#	
#	Locations of input and output images:
infile=$1
outfile=$2


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`

#	controls for the final output:
saturation=60


convert $infile -channel RGB \
	\
	-color-matrix \
		"1 0 0 0 0  \
		 1 0 0 0 0  \
		 1 0 0 0 0  \
		 0 0 0 1 0  \
		 0 0 0 0 1" \
	\
	\( +clone \
		-resize 20%		 \
		-blur	3.0x0.8 	 \
		-median 8.0x3.0 	 \
		-resize "${size}!"	 \
		-blur	2.0x0.7 	 \
		-brightness-contrast 23x33 \
		-channel R -gamma 0.8244 \
		-channel G -gamma 0.9095 \
		-channel B -gamma 1.2130 \
		-channel RGB 		 \
		\( -size ${size} radial-gradient:"#a0a090-#505030" \
			-distort ScaleRotateTranslate '1.05,0' \
			-channel R -function polynomial 1.0,0.0 \
			-channel G -function polynomial 1.0,0.0 \
			-channel B -function polynomial 1.0,0.0 \
			-channel RGB \
			-modulate 100,$saturation \
		\) \
		-compose Overlay -composite \
	\) \
	\
	\( -clone 0 \
		-channel R -gamma 1.2 \
		-channel G -gamma 1.0 \
		-channel B -gamma 0.7 \
		-channel RGB \
		\
	\) -delete 0 \
	-compose blend -define compose:args=45 -composite \
	\
	$outfile
	