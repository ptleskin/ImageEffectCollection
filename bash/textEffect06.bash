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
fontface='../fonts/EVILDEAD.TTF'

# Image textures, 01 over font, 0B at background:
texture01="textEffect06/texture01.png"
texture0B="textEffect06/texture02.png"

# controls how widely the flaky background texture spreads on back of the font:
# percentage are relative distances from the font:
# 0% as wide as possible, 50% at the edge of the font, >50% inside font
bglevels="30%,60%"


# Color lookup tables for color effects:
clut1="textEffect06/hald_Fire.png"


# controls the color range:
color=( '#FF0' '#F00' '#FFF8F0' )

# default colors, yellow red white
dcolor=( yellow red white )
dcolor=( yellow "#F00" "#FFFFFF" )


# radius for the stroke around the font:
#stroke='2.0'
# ( and relatively to font size, min r=2.0 )
#strokesize=`echo "scale=2; r=$stroke*$fontsize/256.0; if (r<1.0) 1.0 else r" | bc`


# Functions for scaling relatively to font size, `sf 100` -> value scaled to font size
function sf {
echo `echo $(($1*$fontsize/256))`
}
function sfd {
echo `echo "scale=2; $1*$fontsize/256" | bc`
}

# Column matrix of desired colors:
A=( 	`convert -size 1x1 xc:${color[0]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${color[1]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${color[2]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${color[0]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${color[1]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${color[2]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${color[0]} -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:${color[1]} -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:${color[2]} -format "%[fx:u.b]" info:` )


# Column matrix of default colors:
B=( 	`convert -size 1x1 xc:${dcolor[0]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${dcolor[1]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${dcolor[2]} -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:${dcolor[0]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${dcolor[1]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${dcolor[2]} -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:${dcolor[0]} -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:${dcolor[1]} -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:${dcolor[2]} -format "%[fx:u.b]" info:` )

## Inverting matrix B
function subdet {
echo `echo "scale=8; ${B[$1]}*${B[$4]}-${B[$2]}*${B[$3]}" | bc`
}

det4578=`subdet 4 5 7 8`
det3568=`subdet 3 5 6 8`
det3467=`subdet 3 4 6 7`
det1278=`subdet 1 2 7 8`
det0268=`subdet 0 2 6 8`
det0167=`subdet 0 1 6 7`
det1245=`subdet 1 2 4 5`
det0235=`subdet 0 2 3 5`
det0134=`subdet 0 1 3 4`

detB=`echo "scale=8; 1.0/(${B[0]}*$det4578-${B[1]}*$det3568+${B[2]}*$det3467)" | bc`

B=( `echo "scale=5; $detB*$det4578" | bc` 
	`echo "scale=5; -1*$detB*$det1278" | bc` 
	`echo "scale=5; $detB*$det1245" | bc` 
	`echo "scale=5; -1*$detB*$det3568" | bc` 
	`echo "scale=5; $detB*$det0268" | bc` 
	`echo "scale=5; -1*$detB*$det0235" | bc` 
	`echo "scale=5; $detB*$det3467" | bc` 
	`echo "scale=5; -1*$detB*$det0167" | bc` 
	`echo "scale=5; $detB*$det0134" | bc` )

# echo ${B[*]}

# matrix product for -color-matrix
AB=( `scale=5; echo "${A[0]}*${B[0]}+${A[1]}*${B[3]}+${A[2]}*${B[6]}" | bc` 
 `scale=5; echo "${A[0]}*${B[1]}+${A[1]}*${B[4]}+${A[2]}*${B[7]}" | bc` 
 `scale=5; echo "${A[0]}*${B[2]}+${A[1]}*${B[5]}+${A[2]}*${B[8]}" | bc`
 `scale=5; echo "${A[3]}*${B[0]}+${A[4]}*${B[3]}+${A[5]}*${B[6]}" | bc` 
 `scale=5; echo "${A[3]}*${B[1]}+${A[4]}*${B[4]}+${A[5]}*${B[7]}" | bc` 
 `scale=5; echo "${A[3]}*${B[2]}+${A[4]}*${B[5]}+${A[5]}*${B[8]}" | bc` 
 `scale=5; echo "${A[6]}*${B[0]}+${A[7]}*${B[3]}+${A[8]}*${B[6]}" | bc` 
 `scale=5; echo "${A[6]}*${B[1]}+${A[7]}*${B[4]}+${A[8]}*${B[7]}" | bc` 
 `scale=5; echo "${A[6]}*${B[2]}+${A[7]}*${B[5]}+${A[8]}*${B[8]}" | bc` )

#	echo ${AB[*]}



convert -size $size2 \
    	-background none -fill white \
    	-font $fontface -pointsize $fontsize \
        -interline-spacing `sf -25` \
        -kerning 12 \
    	-gravity $align \
    	caption:"$label" \
	\
	-gravity Center -extent $size \
	-write mpr:mask \
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
		-channel GB \
		-function polynomial `sfd 4.0`,0,`sfd -0.6` \
		-virtual-pixel mirror \
		-bias 50% \
		-define convolve:scale=1 \
		-channel G \
			-morphology Convolve "3x3:1,0,-1 2,0,-2 1,0,-1"  \
		-channel B \
		-bias 50% \
		-define convolve:scale=1 \
			-morphology Convolve "3x3:1,2,1 0,0,0 -1,-2,-1" \
		-depth 8 \
		-write mpr:dstmap \
		-filter Cubic -resize 25% \
		\( $clut1 -modulate 100,200,90 \
			-color-matrix "${AB[*]}" \
			-function polynomial 2,-1 \
			-channel A -function polynomial 3,0 +channel \) \
		-channel RGBA \
		-hald-clut \
		-resize $size\! \
		-write mpr:texture1 \
	\) \
	\
	\( $texture0B \
		-filter Cubic -resize "`sf 100`%" \
		\( -size 1x1 xc:black xc:${color[1]} xc:${color[0]} +append \
			-filter Cubic -resize 256x1\! \) \
		-clut \
		-set option:distort:viewport $size+0+0 \
		-virtual-pixel Mirror -filter point -distort SRT 0 +repage \
		\( \
			+clone \
			\( mpr:dstmap \
				-channel R -separate +channel \
				-level $bglevels \
			\) \
			-compose Mathematics -define compose:args='2,0,0,0' \
			-composite \
			-alpha shape \
		\) \
		-compose CopyOpacity -composite \
	\) \
	\
	\( -size $size xc:white -fill ${color[0]} -colorize 50% \
		mpr:mask -compose CopyOpacity -composite \
		-filter Cubic -resize 25% \
		-distort SRT "0,0 1 0 0,2" \
		-resize 400% \
	\) \
	\
	\
	\( $texture01 \
		-roll "+0+0" +repage \
		-filter Cubic -resize "`sf 80`%" \
		-color-matrix "${AB[*]}" \
		-set option:distort:viewport $size+0+0 \
		-virtual-pixel Mirror -filter point -distort SRT 0 +repage \
		\
		\( mpr:texture1 \) \
		+swap -compose Hardlight -composite \
		\
		\( mpr:mask \
			-background black -compose SrcOver -flatten \
			-filter Cubic -resize "$((25*256/$fontsize))%" -resize $size\! \
			\
	-write level2.png \
			 -alpha shape \
		\) \
		-compose CopyOpacity -composite \
	\) \
	\
	-delete 0 \
    	-compose SrcOver -background none -flatten \
	-crop $size+0+0 +repage \
	\
	$infile -compose DstOver -composite \
	$outfile


