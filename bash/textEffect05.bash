#
#	Image Effect
#	Espoo, Finland, August 2013
#	Petri Leskinen, petri.leskinen@icloud.com
#
# Creates text element with a transparent background
# Usage:
# bash effectText4.bash 'Lorem...' bground.png output.png 50 Center
# For solid background:
# bash effectText4.bash 'Neon Ipsum …' '-size 600x400 xc:none' output.png 90 NorthWest


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
paddingV=20

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"


# Text parameters:
linespacing=$((-25*$fontsize/100))
fontface='../fonts/Portcullion.ttf'

# Image textures, 01 over font, 0B at background:
texture01="textEffect05/texture01.png"
texture0B="textEffect05/textureBack.png"

# Color lookup tables for color effects:
clut="textEffect05/hald_GT_1.png"
clut2="textEffect05/hald_GT_2.png"

# DropShadow, radiusxsigma+x+y:
# DropShadow = ( radius, sigma, +x, +y ) :
drop=( 9 3  0 8 )
# intensity: 1.0-normal .. 2.0-high:
dropshadowintensity=4

# ( scale to font size: )
dropshadow="$((${drop[0]}*$fontsize/256+1))x$((${drop[1]}*$fontsize/256+1))+0+0"


# controls the color range:
color1='#FF0' # default yellow
color2='#F00' # default red
color3='#FFF' # default white


# radius for the stroke around the font:
stroke='2.0'
# ( and relatively to font size, min r=2.0 )
strokesize=`echo "scale=2; r=$stroke*$fontsize/256.0; if (r<1.0) 1.0 else r" | bc`

# Controls the strength of the background effect,
# small values "5%x5%" give a larger area:
backgroundeffect="10%x50%"

# Functions for scaling relatively to font size, `sf 100` -> value scaled to font size
function sf {
echo `echo $(($1*$fontsize/256))`
}
function sfd {
echo `echo "scale=2; $1*$fontsize/256" | bc`
}

# Column matrix of desired colors:
A=( 	`convert -size 1x1 xc:$color1 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color1 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color1 -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.b]" info:` )

# Inverse color matrix 
# inverse( yellow | red | white )
B=( 0 1 -1 1 -1 0 0 0  1 )

# matrix product for -color-matrix
AB=( `scale=4; echo "${A[0]}*${B[0]}+${A[1]}*${B[3]}+${A[2]}*${B[6]}" | bc` 
 `scale=4; echo "${A[0]}*${B[1]}+${A[1]}*${B[4]}+${A[2]}*${B[7]}" | bc` 
 `scale=4; echo "${A[0]}*${B[2]}+${A[1]}*${B[5]}+${A[2]}*${B[8]}" | bc`
 `scale=4; echo "${A[3]}*${B[0]}+${A[4]}*${B[3]}+${A[5]}*${B[6]}" | bc` 
 `scale=4; echo "${A[3]}*${B[1]}+${A[4]}*${B[4]}+${A[5]}*${B[7]}" | bc` 
 `scale=4; echo "${A[3]}*${B[2]}+${A[4]}*${B[5]}+${A[5]}*${B[8]}" | bc` 
 `scale=4; echo "${A[6]}*${B[0]}+${A[7]}*${B[3]}+${A[8]}*${B[6]}" | bc` 
 `scale=4; echo "${A[6]}*${B[1]}+${A[7]}*${B[4]}+${A[8]}*${B[7]}" | bc` 
 `scale=4; echo "${A[6]}*${B[2]}+${A[7]}*${B[5]}+${A[8]}*${B[8]}" | bc` )



convert -size $size2 \
    	-background none -fill white \
    	-font $fontface -pointsize $fontsize \
        -interline-spacing `sf -25` \
        -kerning 3 \
    	-gravity $align \
    	caption:"$label" \
	\
	-gravity Center -extent $size \
	-write mpr:mask \
	\
    \( mpr:mask -background black -virtual-pixel none \
        +depth -filter Cubic -resize $backgroundeffect -auto-level \
        \( +clone -distort SRT "0,0 1 0 0,1"  \) \
        \( -clone 0 -distort SRT "0,0 1 0 0,-1"  \) \
        -compose Lighten -flatten \
        -function polynomial 1,0 \
        -resize $size\! \
        \(  $texture0B \
	     -resize "`sf 100`%" \
            -set option:distort:viewport $size+0+0 \
            -virtual-pixel Mirror -filter point -distort SRT 0 +repage \
	\) \
       -compose Multiply -composite \
      	-channel RGBA \
       -color-matrix \
    		'1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0' \
    	+channel \
	+level-colors none,red \
       \) \
	\
	\
	\( 	mpr:mask -function polynomial 0 -background black \
			-shadow $dropshadow \
			-channel A -function polynomial 16,0 +channel \
			-distort SRT "0,0 1 0 0,`sf ${drop[3]}`" +repage \
      \) \
      \
	\( mpr:mask \
	-background black -alpha remove \
	+depth \
	\
	\( +clone -virtual-pixel edge \
		-morphology Edge Square:1 \
		-negate -morphology Distance Euclidean:5 \
		-function polynomial $((5*256/fontsize)),0 \
	\) \
        -compose Mathematics -define compose:args='2,-1,0,0.5' \
	-composite \
	-channel GB \
	-function polynomial `sfd 3.0`,0,0 \
	-bias 50% \
	-define convolve:scale=1 \
	-channel G \
		-morphology Convolve "3x3:1,0,-1 2,0,-2 1,0,-1"  \
	-channel B \
	-bias 50% \
	-define convolve:scale=1 \
		-morphology Convolve "3x3:1,2,1 0,0,0 -1,-2,-1" \
	-channel RGB \
	-function polynomial 1.0,-0.0 \
	-depth 8 \
	-write mpr:distmap \
	\
	\( $clut -color-matrix "${AB[*]}" \) \
	-hald-clut \
	-channel RG -function polynomial 2,-0.2 +channel \
	\
	\(  $texture01 \
	     -resize "`sf 100`%" \
            -set option:distort:viewport $size+0+0 \
            -virtual-pixel Mirror -filter point -distort SRT 0 +repage \
		-function polynomial 0.4,0.3 \
		\) \
       -compose Hardlight -composite \
	-brightness-contrast 40x50 \
	\
	mpr:mask -compose CopyOpacity -composite \
	\
	\( +clone -distort SRT "0,0 1 0 -$strokesize,0" \
 		\( +clone -distort SRT "-$strokesize,0 1 0 $strokesize,0"  \) \
       	\( +clone -distort SRT "0,0 1 0 -$strokesize,-$strokesize"  \) \
       	\( +clone -distort SRT "0,-$strokesize 1 0 0,$strokesize"  \) \
		-compose SrcOver  -background none -flatten +repage \
	\) \
	+swap -compose SrcOver -flatten +repage \
	\) \
	\
	\( mpr:distmap -filter Cubic \
		-virtual-pixel black -resize 50% \
		-function polynomial 1,-0.05 \
		-channel RGBA $clut2 -hald-clut +channel \
		-channel A -function polynomial 1.4,-0.4 +channel \
		-resize 50% -resize 400% \
       \
	\) \
	-gravity NorthWest \
    -delete 0 \
    -compose SrcOver -background none -flatten \
	-crop $size+0+0 +repage \
	\
	$infile -compose DstOver -composite \
	$outfile


