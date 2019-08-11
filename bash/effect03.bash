#
#	Espoo, Finland, October 2012
#	Petri Leskinen, petri.leskinen@aalto.fi
#	
#	bash effect03.bash [input image] [texture image] [output image]
#	example of usage:
#	bash effect03.bash ../images/gumbole_mansion.jpg ../images/texture.jpeg ../result_images/effect03.jpg


#	Locations of input and output images:
infile=$1 
outfile=$3 

#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`

# paper texture,
# source: http://lostandtaken.com/blog/2010/1/26/8-re-stained-paper-textures.html
texturefile=$2

# strength of paper texture 0.0...1.0,
texturealpha="0.5"

# local contrast inside image 0.1: normal, 0.99:exaggerated
contrast="1.4"


# amount of dark parts in image, gamma value, 0.4:dark 1:normal, 2.5:light
dark="1.0"

# strength of vignetting 0...100%

# vignette0 = start at transparent end, 0 all the way to edges
# vignette1 = end at opaque end, 1 to show entire image
vignette0="30%"
vignette1="90%"


# Overall shades, "rgb(255,128,0)", "#RGB" or "#RRGGBB" :
darkShade="#205070"
lightShade="#9ad3e5"


# size for temporary bitmaps for vignetting etc.
newsize="92x92^"

# factors for black'n'white conversion :
toBW="3 5 1 0 "

# matrix for distance kernel :
erodion='3x3: 3 2 3  2 0 2  3 2 3'

# controls the edge areas drawn as line art:
#  stroke width:
strokeBlur="1x0.5"
#  stroke 'strength':
strokeBlur2="3x1"

# alpha for stroke at edges 0.0...1.0
# strokeAlpha=0.3
#  stroke 'smoothness' 1.0: lot of details, 1.3: sharp :
strokeAmount="1.15"

# strength of edges in aquarelle pattern:
aquaEdges="0.05"
# size of aquarelle pattern at center:
aquaSize="2"
# size of aquarelle pattern at edges:
aquaSize2="6"

convert $infile \
	-auto-level -modulate 100,0 -gamma "$dark" \
		-write mpr:source \
	-function polynomial 1.2,-0.1 \
	-morphology Convolve "3x3: -0.2 -0.3 -0.2  -0.3 3 -0.3  -0.2 -0.3 -0.2" \
	-resize "${newsize}" \
	-virtual-pixel edge \
	\( -clone 0 \
		\( +clone -distort SRT "0,0 1 0 1,0" \) \
	-compose Difference -composite \) \
	\( -clone 0 \
		\( +clone -distort SRT "0,0 1 0 0,1" \) \
	-compose Difference -composite \) \
	\( -clone 0 \
		\( +clone -distort SRT "1,0 1 0 0,0" \) \
	-compose Difference -composite \) \
	\( -clone 0 \
		\( +clone -distort SRT "0,1 1 0 0,0" \) \
	-compose Difference -composite \) \
	-delete 0 \
	-negate -compose Darken -flatten -negate \
	-color-matrix "$toBW $toBW $toBW  0 0 0 1" \
	-auto-level \
	-depth 16 \
	-function polynomial 0.0078125,0.0 \
	-function polynomial 1,-0.001 \
	-function polynomial 1,0.001 \
	-write mpr:dist \
	\
	\
	-function polynomial 1 \
	-virtual-pixel black \
	-distort SRT "0,0 1 0 0,2" \
	-distort SRT "0,3 1 0 0,2" \
	-write mpr:mask \
	\
	-virtual-pixel edge \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	-virtual-pixel edge \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	\( +clone -morphology Erode "${erodion}" mpr:dist -compose Plus -composite \) \
		-compose Darken -composite \
	-equalize -morphology Dilate Disk:3 \
	-write mpr:mask \
	-delete 0 \
	\
	\( mpr:source 			\
		-virtual-pixel edge 	\
		-morphology Convolve "3x3: 0.4 0.6 0.4  0.6 -4 0.6  0.4 0.6 0.4" \
		-blur $strokeBlur 	\
		\( +clone \
			-channel All -random-threshold 0%,25% \
			-blur $strokeBlur2 -function polynomial 2,0 +channel \
		\) \
		-average -auto-level \
		-function polynomial -1,$strokeAmount \
	\) \
	\
	\( mpr:source -blur 2x0.6 -paint $aquaSize2 \
		\( +clone -resize 5% \
			-negate -resize "${size}!" \) \
		-compose Overlay -composite \
		\
		\( +clone \
			-morphology Convolve "3x3: 0.4 0.6 0.4  0.6 -4 0.6  0.4 0.6 0.4" \
			-function polynomial $aquaEdges,0 \) \
		-compose MinusSrc -composite \
		-write mpr:aquarelle \
		\
		\( xc:"#000" xc:"$lightShade" xc:"$lightShade" xc:"#FFF" \
			+append \) \
		-clut \
	\) \
	-compose Multiply -composite \
	\
	\( mpr:source -blur 2x0.6 -paint $aquaSize \
		\( +clone -resize 5% \
			-negate -resize "${size}!" \) \
		-compose Overlay -composite \
		\
		\( +clone -virtual-pixel edge 	\
			-morphology Convolve "3x3: 0.4 0.6 0.4  0.6 -4 0.6  0.4 0.6 0.4" \
			\
			-function polynomial $aquaEdges,0 \) \
		-compose MinusSrc -composite  \
		\( xc:"#000" xc:"$darkShade" \
			\( +clone xc:"#FFF" -average \) \
			xc:"#FFF" +append \) \
		-clut \
		\
		\( mpr:mask \
			-level ${vignette0},${vignette1} \
			-sigmoidal-contrast 10x50% \
			-filter Cubic -resize "${size}!" \
			-depth 8 \
		\) \
		-alpha Off -compose Copy_Opacity -composite \
	\) \
	-compose Over -composite \
	\
	\
	\( $texturefile \
		-resize "${size}^" 	\
		-gravity North 		\
		-extent "${size}!" 	\
		-negate -function polynomial $texturealpha,0 -negate \
	\) -compose Linear_Burn -composite \
	\
	$outfile



