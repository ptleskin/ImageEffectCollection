#	Image Effect with color range
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi
#
#	Script based on photoshop tutorial:
#	  http://www.photoshoproadmap.com/Photoshop-blog/quick-and-simple-worn-out-psychedelic-poster-in-photoshop/
#
#	bash effect04.bash [input image] [texture image] [output image]
#	example of usage:
#	bash effect04.bash ../images/gumbole_mansion.jpg ../images/texture.jpeg ../result_images/effect04.jpg

#	Locations of input and output images:
infile=$1 
outfile=$3


# paper texture,
# source http://spiketheswede.deviantart.com/art/Paper-Texture-3-135239044
texturefile=$2


#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`


#	Colors used in Gradient Map:
spectr=('#382c7f' '#219bd6' '#c40078' '#c32526' '#f9e837' '#41944d')

#	Color saturation:
saturation='92'

convert $infile 	\
	-modulate 100,0 \
	\( 	xc:${spectr[0]} xc:${spectr[1]} \
		xc:${spectr[2]} xc:${spectr[3]} \
		xc:${spectr[4]} xc:${spectr[5]} \
		+append \
		-filter Quadratic  -resize "280x1!" \
		-gravity North -extent "256x1!" \
		-modulate 100,$saturation \)	\
	-clut \
	\
	\( $texturefile \
		-resize "${size}^" 	\
		-gravity North 	\
		-extent "${size}!" 	\
		-function polynomial 0.5,0.25 \
	\) -compose Overlay -composite \
	\
	$outfile
	
	


