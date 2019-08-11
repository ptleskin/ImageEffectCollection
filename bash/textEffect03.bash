#
#	Text Effect
#	Espoo, Finland, August 2013
#	Petri Leskinen, petri.leskinen@icloud.com
#
# Creates text element with a transparent background
# Usage:
# bash effectText6.bash 'Lorem...' bground.png output.png 50 Center
# For solid background:
# bash effectText6.bash 'Neon Ipsum …' '-size 600x400 xc:none' output.png 90 NorthWest


label=$1    # text string ...
infile=$2   # background image ... or '-size 600x400 xc:none'
outfile=$3  # 'outfile.png'
fontsize=$4 # font size, 265 in PS example
if [ -z "$4" ]
  then
    echo "Using default font size of 100"
    fontsize=100
fi

align=$5    # 'center', 'south', 'west', 'northeast' etc ...
if [ -z "$5" ]
  then
    echo "Using default orientation NorthWest"
    align="NorthWest"
fi

#	Size of input image, in format "%wx%h"
size=`convert $infile -format %G info:`
height=`convert $infile -format %h info:`

# padding on left and right sides:
padding=25
# padding on top and bottom sides:
paddingV=0

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"


# Text parameters:
linespacing=$((-25*$fontsize/100))
fontface='../fonts/Molot.otf'


# image holding the pattern inside font:
patternfile='textEffect03/texture01.png'
strokefile='textEffect03/texture02.png'

# stripe pattern around the font contours:
strokegradient='textEffect03/pattern02.png'


# colorize the pattern file: default "black,white"
patternshade="'#151515',white"


# DropShadow, radius, sigma, x, y:
drop=( 15 5 12 18 )
# intensity: 1.0-normal .. 2.0-high:
dropshadowintensity=2.0
# ( scale to font size: )
dropshadow="$((${drop[0]}*$fontsize/256+1))x$((${drop[1]}*$fontsize/256+1))+$((${drop[2]}*$fontsize/256+1))+$((${drop[3]}*$fontsize/256+1))"


# OuterGlow and intensity 0…1
glow=14
glowintensity=0.45
outerglow="$(($glow*$fontsize/256+1))"
outerglow2="$(($glow*$fontsize*7/2560+1))"

# bevel width:
bevel='12.0'
# ( and relatively to font size, min r=2.0 )
bevelsize=`echo "scale=0; r=$bevel*$fontsize/256.0; if (r<2.0) 2.0 else r" | bc`
step=`echo "scale=1; 65536/$bevelsize" | bc`
step2=`echo "scale=1; 92682/$bevelsize" | bc`
distkernel="3x3: $step2,$step,$step2 $step,0,$step $step2,$step,$step2"


# white edge:
edgewidth=`echo "scale=2; r=5*$fontsize/256.0; if (r<1.0) 1.0 else r" | bc`


# downscaling factor for speeding up the highlight search:
# in per cents, suitable values 100,50,25,20,10,5 etc …
samplescale=10


convert -size $size2 \
    	-background none -fill white \
    	-font $fontface -pointsize $fontsize \
    	-interline-spacing $linespacing \
    	-kerning 5.0 \
    	-gravity $align \
    	caption:"$label" \
	\
	-gravity Center -extent $size \
	-write mpr:txt \
	\
	\
	\(  -clone 0 -background black \
		-shadow $dropshadow \
		-channel A \
		-function polynomial $((1024/$fontsize)),0 \
		-gamma $dropshadowintensity \
		+channel \
	\) \
	\
	\(  $strokefile \
		-filter Cubic -resize "$((100*$fontsize/256))%" \
		-set option:distort:viewport $size+1+1 \
		-virtual-pixel Tile -filter point -distort SRT 30 +repage \
		\
		mpr:txt \
		-compose CopyOpacity -composite \
	\) \
	\
	\
	\( \
		\( mpr:txt \
			-background black -alpha remove \
			-morphology Erode Disk:$edgewidth \
			-write mpr:mask2 \
			+delete \
		\) \
		\
		\( \( $patternfile \
			-resize "$((100*$fontsize/256))%" \
			-set option:distort:viewport $size+0+0 \
	   		-virtual-pixel Tile -filter point \
			-distort SRT "0,0 1 0 0,0" +repage \
			\) \
			 \
		   \( 	\( mpr:mask2 \
				-morphology Erode Disk:$bevelsize \
				\) \
			\( mpr:mask2 -negate \) \
			-compose Plus -composite \
			-alpha shape \
			\) \
			-background none \
			-compose CopyOpacity -composite \
		\) \
		\
		-write mpr:mask3 \
		-filter Cubic \
		\( +clone -resize 25%x100% \) \
		\( -clone -2 -resize 100%x25% \) \
		\( -clone -2 -resize  50%x100% \) \
		\( -clone -2 -resize  100%x50% \) \
		\( -clone -2 -resize  50%x50% \) \
		\( -clone -2 -resize  25%x25% \) \
		-layers RemoveDups -resize $size\! \
		-reverse -background none \
		-compose SrcOver -flatten \
		\
		-define convolve:scale=\! \
		-bias 0% -morphology Convolve \
		"3x3:-1,0,-1 -1,6.5,-1 -1,0,-1" \
		\
		mpr:mask3 -background none \
		-compose SrcOver -flatten \
		\
		-alpha remove \
		\( mpr:mask2 \
			-morphology Distance "$distkernel" \
			-define convolve:scale=\! \
			-bias 45% -morphology Convolve "3x3:0,2,0 1,0,-1 0,-2,0" \
			-function polynomial 7,-3 \
		\) \
		 +swap -compose Overlay -composite \
		-gamma 0.7 \
		+level-colors $patternshade \
		\
		\( mpr:mask2  -alpha shape \) \
		-compose CopyOpacity -composite \
		\
	\) \
	\
	-compose SrcOver -background none -flatten \
	-gravity NorthWest -crop $size+0+0 +repage \
	\
	$infile -compose DstOver -composite \
	$outfile

