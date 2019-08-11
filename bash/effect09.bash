#	Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1
outfile=$2

#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


#	Parameters for blur and median filter radii:
blurRadius=18
medianRadius=30

#	Gamma parameters for color correction:
cb_R='0.62634'
cb_G='1.0083'
cb_B='1.13'

# Shades of Lighting Effect:
vignetteCenter='gray(50%)'
vignetteEdge='gray(5%)'

convert $infile \
	\( +clone -resize 25% \
		-blur $((${blurRadius}/4))x$((${blurRadius}/4)) \
		-median $((${medianRadius}/4))x1 \
		-channel R -gamma ${cb_R} \
		-channel G -gamma ${cb_G} \
		-channel B -gamma ${cb_B} \
		-channel RGB \
		-resize "${size}!" \
		\
		\( -size ${size} \
			radial-gradient:"${vignetteCenter}-${vignetteEdge}" \
			-resize 135%x170% -gravity SouthWest -extent "${size}!" \
		\) \
		-compose Plus -composite \
		\
		-alpha on -channel A -function polynomial 0.71 \
	\) \
	-compose Over -composite \
	$outfile
