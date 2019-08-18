#
#	Text Effect
#	Espoo, Finland, August 2013
#	Petri Leskinen, petri.leskinen@icloud.com
#
# Creates text element with a transparent background
# Usage:
# bash textEffect01.bash 'Gumböle Manor' ../images/gumbole_mansion.jpg output.png 160 SouthWest
# For solid background:
# bash textEffect01.bash 'Neon Ipsum …' '-size 600x400 xc:none' output.png 90 NorthWest


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

# padding on left and right sides:
padding=25
# padding on top and bottom sides:
paddingV=12

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"

# Ambient color, default magenta:
color1='#FF00FF'

# Text parameters:
linespacing=$((-1*fontsize/3))
fontface='../fonts/AIRSTREA.TTF'

# Shadow Offset:
shadowA=$((40*$fontsize/300+1))
shadowX=$((10*$fontsize/300+1))
shadowY=$((17*$fontsize/300+1))
blurA=$((50*$fontsize/300+1))
blurS=$((25*$fontsize/300+1))
blurXY=$(($fontsize/8+1))
innerGlow="$((18*$fontsize/300+1))x$((5*$fontsize/300+1))"

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
	\( +clone -background $color1 -shadow "$shadowA"x3+$shadowX+$shadowY \
		\( +clone -background $color1 -shadow "$blurA"x"$blurS"+0+0  \
			-filter point -distort SRT "$((2*$shadowX)),$((2*$shadowY)) 1 0  0,0" \
			\( +clone -filter point -distort SRT "$blurXY,0 1 0  0,0" \) \
			\( +clone -clone -2 -filter point -distort SRT "0,$blurXY 1 0  0,0" \) \
			-compose plus -background none -flatten \
		\) \
		-compose plus -background none -flatten -channel A -gamma 2.0 +channel \
	\) \
	\( mpr:txt \
		-blur $innerGlow \
		-function polynomial 1.1,-0.1 +level-colors $color1,white \
		\) \
	-compose SrcOver -background none -flatten \
	-gravity NorthWest -crop $size+0+0 +repage \
	\
	miff:- | convert $infile \( - -channel A -gamma 1.41 +channel \) \
	-flatten \
	$outfile

