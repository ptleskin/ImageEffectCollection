
#	Image Effect 		
#	Espoo, Finland, September 2012 		
#	Petri Leskinen, petri.leskinen@aalto.fi 
#	bash effect03.bash [input image] [pattern image] [output image]
#	example of usage:
#	bash effect12.bash ../images/gumbole_mansion.jpg ../images/pattern.png ../result_images/effect12.jpg


#	Locations of input, pattern and output images: 
infile=$1
patternFile=$2
outfile=$3


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


#	
brightness='0'
contrast='-30'
saturation=100
patternScale='1'


convert $infile -channel RGB -modulate 100,0 \
	\
	\( +clone -function polynomial 5,-2.5 \) \
	-compose Lighten -composite \
	\
	\( +clone \
		\( +clone -negate -blur 5x2 \)	\
		-compose Plus -composite 	\
		-function polynomial 1,0,0 	\
	\) -compose blend -define compose:args=50,50 -composite \
	\
	\( $infile -alpha on \
		-color-matrix \
			"0.2 0.7 0.1 0 0, \
			 0.2 0.7 0.1 0 0, \
			 0.2 0.7 0.1 0 0, \
			 -3 -3 -2 3.5 0, \
			 0 0 0 0 1" \) \
	-compose Over -composite \
	\
	-function polynomial 0.8,0.0 		\
	\( -size ${size} xc:'#000' 		\
		-attenuate 20 +noise Uniform 	\
		-modulate 100,0 		\
	\) -compose Plus -composite 		\
	\
	\
	-auto-level 	\
	\( +clone 	\
		\( -size ${size} tile:${patternFile} \
			-distort SRT "0,0 ${patternScale},${patternScale} 0" \) \
		-compose Hard_Light -composite \
		-convolve "0 0 0 0 1  0 0 0 1 0  0 0 1 0 0  0 1 0 0 0  1 0 0 0 0" \
	\) -compose blend -define compose:args=50,50 -composite \
	\
	\
	\( +clone -auto-level \) \
	-compose blend -define compose:args=50,50 -composite \
	\
	-brightness-contrast $brightness,$contrast \
	\
	$outfile
