#
#	Image Effect
#	Espoo, Finland, September 2013
#	Petri Leskinen, petri.leskinen@icloud.com
#
# Creates text element with a transparent background
# Usage:
# bash textEffect07.bash 'Gumböle Mansion' ../images/gumbole_mansion.jpg output.png 120 South
# For solid background:
# bash textEffect07.bash 'Neon Ipsum …' '-size 600x400 xc:none' output.png 90 NorthWest


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
padding=20
# padding on top and bottom sides:
paddingV=20

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"


# Text parameters:
fontface='../fonts/PrimeScript.ttf'


# image holding the pattern inside font:
texturefile='textEffect07/texture01.png'

# font and background colors:
colors=( '#d5a5b3' '#511' )
colors=( '#c777bd' '#151' )
colors=( '#77bdc7' '#511' )

# overall brightness and saturation:
saturation="100,130"

# DropShadow, start%, end%, x, y:
drop=( 44 47 3 12 )
# intensity: 1.0-normal .. 2.0-high:
dropalpha=0.84

# Outer Glow:
#  controls glow range around the font. 
#  large area "0%,50%", narrow "45%,50%" 
glow="35%,50%"
glowalpha=0.8


# Function for scaling relatively to font size, `sf 100` -> value scaled to font size
function sf {
    echo `echo $(($1*$fontsize/256))`
}
function sfd {
    echo `echo "scale=2; $1*$fontsize/256" | bc`
}



convert -size $size2 \
    	-background none -fill white \
    	-font $fontface -pointsize $fontsize \
    	-interline-spacing `sf 5` \
    	-kerning `sfd 5.0` \
    	-gravity $align \
    	caption:"$label" \
	\
	-gravity Center -extent $size \
	-background black \
	-write mpr:mask +delete \
	\
	$infile \
	\
	\( mpr:mask \
	    	-background black -alpha remove \
		+depth \
		\
		\( +clone \
			-morphology Edge Square:1 \
			-negate -morphology Distance Euclidean:5 \
			-function polynomial $((5*256/fontsize)),0 \
		\) \
	      -compose Mathematics -define compose:args='2,-1,0,0.5' \
		-composite \
		-write mpr:dstmap +delete \
	\) \
	\
	\(  -size $size xc:${colors[1]} -modulate $saturation \
		\( mpr:dstmap \
			-distort SRT "0,0 1 0 `sfd ${drop[2]}`,`sfd ${drop[3]}`" \
			-level "${drop[0]}%,${drop[1]}%" \
			-evaluate multiply $dropalpha \
			-alpha shape \
		\) \
		-compose CopyOpacity -composite \
		\
	\) \
	\
	\(  -size $size xc:${colors[1]} -modulate $saturation \
		\( mpr:dstmap \
			-level $glow -evaluate multiply $glowalpha \
			-alpha shape \
		\) \
		-compose CopyOpacity -composite \
	\) \
	\
	\( \
		\(  $texturefile  \
			-function polynomial 0.8,0.1 \
			-set option:distort:viewport $size+0+0 \
			-virtual-pixel Mirror -filter Point \
			-distort SRT "0,0 `sfd 1.0` 0 0,0" \
			\( -size $size xc:${colors[0]} \) \
			-compose Hardlight -composite \
		\) \
		\
		\( mpr:mask -background black -alpha remove \
			-bias 50% -define convolve:scale=3 \
			-morphology Convolve "1x5:2 4 0 -4 -2" \
			-bias 0% -define convolve:scale=\! \
			-morphology Convolve "1x3:1 2 1" \
			-distort SRT "0,0 1 0 0,1" \
			\( mpr:dstmap -level 20%,60% \) \
			+swap -compose Hardlight -composite \
		\) \
		-compose Multiply -composite \
		-modulate $saturation \
		\
		mpr:mask \
		-compose CopyOpacity -composite \
		-distort SRT "0,0 1 0 `sfd 0.0`,`sfd 0.0`" +repage \
		\
	\) \
	\
	-gravity NorthWest \
	-compose SrcOver -background none -flatten \
	$outfile

