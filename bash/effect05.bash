#	Image Effect
#	Espoo, Finland, September 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi
#
#	bash effect05.bash [input image] [output image]
#	example of usage:
#	bash effect05.bash ../images/gumbole_mansion.jpg ../result_images/effect05.jpg

#	Locations of input and output images:
infile=$1 
outfile=$2 


#	parameters for pattern, integers:
hipassRadius=80
hipassSaturation="-modulate 100,0"

# fine-tune for final output:
brightness='100' # 100 in photoShop action
saturation='50'	 # 71 in photoShop action

# general gamma for mid tones:
gammaRGB='1.0'

# gamma for each color channel:

gammaR='1.05'		# '1.0' in photoshop
gammaG='1.1158'		# '1.0958'
gammaB='0.9148'		# '0.9148'

# Channel Mix in ps-action
monochrom="0.4 0.4 0.2 0"


# Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


cb_R=`echo "scale=5;${gammaR}*${gammaRGB}" | bc -l`
cb_G=`echo "scale=5;${gammaG}*${gammaRGB}" | bc -l`
cb_B=`echo "scale=5;${gammaB}*${gammaRGB}" | bc -l`


convert $infile -channel RGB \
	\( \
		+clone \
			\( +clone $hipassSaturation \
				-virtual-pixel mirror \
				-function polynomial -2,1.5 \
				-blur 77x26 \
				-function polynomial 0.68.0.16 \
			\) \
		-compose Overlay -composite \
	\) \
	\( \
		-clone 1 \
			\( -clone 0 $hipassSaturation \
				-virtual-pixel mirror \
				-function polynomial -1.9,1.9 \
				-blur 98x33 \
				-function polynomial 0.13,0.435 \
			\) \
		-compose Overlay -composite \
	\) \
	-delete 0,1 \
	-modulate 100,80 \
	\
	-gamma 1.2 \
	\
	\( +clone -color-matrix "${monochrom} ${monochrom} ${monochrom} 0 0 0 1" \) \
	-compose Multiply -composite \
	\
	-write mpr:tmp01 \
	\
	\
	\( +clone $hipassSaturation \
		-virtual-pixel mirror -blur 81x27 -negate \
	\) \
	-compose blend -define compose:args=40,60 -composite \
	\
	mpr:tmp01 \
	-compose Lighten -composite \
	\
	\
	\
	mpr:tmp01 \
	-compose blend -define compose:args=78 -composite \
	\
	mpr:tmp01 \
	+swap -compose Soft_Light -composite \
	\
	-modulate 100,70 \
	\
	\( +clone -colors 1 $hipassSaturation -negate \) \
	-compose Soft_Light -composite \
	\
	-channel R -gamma ${cb_R} \
	-channel G -gamma ${cb_G} \
	-channel B -gamma ${cb_B} \
	-channel RGB -modulate ${brightness},${saturation} \
	\
	$outfile








