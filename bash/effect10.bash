#	Sepia Toned Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1
outfile=$2

#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`

#	parameters for adjusting the final output:
noise=6
brightness=0
contrast=12


convert \( $infile \
	-unsharp 120x1+0.1+0 \
	\( +clone \
		-alpha Set -alpha On \
		-channel RGBA \
		-color-matrix \
     			"1 0 0 0 0 \
     			 0 1 0 0 0 \
     			 0 0 1 0 0 \
     			 0.298839 0.586811 0.11435 0 0 \
			 0 0 0 0 1" \
		-blur 0x1.4 \
		-channel A -level 60%,75% \
		-channel RGBA \
		\
	\) \
	-flatten \
	\
	\( +clone \
		-function polynomial 1,-0.6 \
		-channel RGB -separate \
		\( -size ${size} radial-gradient:'#000'-'#FFF' \
			-distort ScaleRotateTranslate '1.33,0' \
			-auto-level \
			-function polynomial 0.1569,0.3804,0.3255 \
			-channel R -separate \
		\) \
		-channel RGBA -combine \
	\) \
	-flatten \
	-function polynomial 1,-1.5,1.5,0 \
	\( +clone \
		-alpha Set -alpha On \
		-channel RGBA \
		-color-matrix \
     			"1 0 0 0 0 \
     			 0 1 0 0 0 \
     			 0 0 1 0 0 \
     			 0.298839 0.586811 0.11435 0 0 \
			 0 0 0 0 1" \
		-blur 20x7 \
		-channel A -function polynomial 5,-4 \
		-channel RGBA \
		\
	\) \
	-flatten \
	\
	-channel RGB \
	-function polynomial 1.3333,-2,1.6667,0 \
	-alpha set -channel RGBA \
	-color-matrix \
		"0.06	0.06	0.86	-0.08 \
		 0.06	0.06	0.86	-0.08 \
		 0.06	0.06	0.86	-0.08 \
		 0 	0 	0 	1" \
	-channel R -function polynomial 0.9608,0.0392 \
	-channel G -function polynomial 0.9725,0 \
	-channel B -function polynomial 0.8784,0 \
	-channel RGB -function polynomial 1.3797,-2.8986,2.3621,0.0549 \
	-brightness-contrast $brightness,$contrast \
	\
	\( -size ${size} xc:'#808080' \
		-attenuate $((2*noise)) +noise Uniform -modulate $((100-noise)),0 \
	\) \
	-compose Overlay -composite \
	\
	-blur 0x0.5 \) \
	$outfile
