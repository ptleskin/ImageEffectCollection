#
#	Image Effect 
#	Espoo, Finland, August 2013
#	Petri Leskinen, petri.leskinen@icloud.com
#
# Creates text element with a transparent background
# Usage:
# bash textEffect02.bash 'Lorem...' bground.png output.png 50 Center
# For solid background:
# bash textEffect02.bash 'Neon Ipsum …' '-size 600x400 xc:none' output.png 90 NorthWest


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
paddingV=10

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"


# Text parameters:
linespacing=$((-23*$fontsize/100))

fontface='../fonts/SLANT.TTF'


# image holding the pattern inside font:
patternfile='textEffect02/pattern01.png'
patternheight=`convert $patternfile -format %h info:`

# colorize the pattern file: default "black,white"
# GOLD: patternshade="black,'#FA3'"
# COLD: patternshade="'#111140','#00F0FF'"
patternshade="black,white"


# stripe pattern around the font contours:
strokegradient='textEffect02/pattern02.png'


# Image file of the highlight flare:
flarefile='textEffect02/highlight.png'
flarewidth=`convert $flarefile -format %w info:`
flareheight=`convert $flarefile -format %h info:`

# image for detecting the highlights:
hilitefile='textEffect02/highlightdetect.png'

# DropShadow, radiusxsigma+x+y:
dropshadow="$((16*$fontsize/256+1))x3+0+$((16*$fontsize/256))"
# intensity: 1.0-normal .. 2.0-high:
dropshadowintensity=1.33

# OuterGlow, radiusxsigma+x+y:
outerglow="$((36*$fontsize/256+1))x$((12*$fontsize/256+1))+0+0"
outglowintensity=1.8

# radius for the stroke around the font:
stroke='6.0'
# ( and relatively to font size, min r=2.0 )
strokesize=`echo "scale=2; r=$stroke*$fontsize/256.0; if (r<2.0) 2.0 else r" | bc`
#echo $strokesize


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
	\( 	+clone -background black \
			-shadow $dropshadow \
			-channel A -gamma $dropshadowintensity +channel \) \
	\
	\( 	-clone 0 -background '#F6F3E7' \
			-morphology Dilate Disk:3.0 \
			-shadow $outerglow \
			-channel A -gamma $outglowintensity +channel \) \
	\
	\(  $strokegradient \
		-filter Cubic -resize "$((100*$fontsize/256))%" \
		-set option:distort:viewport $size+1+1 \
		-virtual-pixel Tile -filter point -distort SRT 0 +repage \
		\
		\( mpr:txt -channel A \
			-morphology Dilate Disk:$strokesize \
			+channel \) \
		-compose CopyOpacity -composite \
	\) \
	\
	\( 	\( mpr:txt -distort SRT "0,0 1 0 0,1"  +level-colors none,'#333' \) \
		\( mpr:txt -roll +0-1 +level-colors none,white \) \
		\( mpr:txt -roll -1+0 +level-colors none,'#888' \
			\( +clone -roll +2+0 \) \) \
		+level-colors $patternshade \
		-compose SrcOver -background none -flatten \
	\) \
	\( \
		\( \
			$patternfile \
			+level-colors $patternshade \
			-resize "$((100*$fontsize/256))%" \
			-set option:distort:viewport $size+1-$paddingV \
		   	-virtual-pixel Tile -filter point \
			-distort SRT "0,0 1 0 0,0" +repage \
			\
		mpr:txt -compose CopyOpacity -composite \
		\) \
		\
	\) \
	\
	-compose SrcOver -background none -flatten \
	-gravity NorthWest -crop $size+0+0 +repage \
	\
	$infile -compose DstOver -composite \
	-write $outfile -delete 0 \
	\
	\( \
		$hilitefile \
		-resize "$((100*$fontsize/256))%" \
		-set option:distort:viewport $size+1-$paddingV \
		-virtual-pixel Tile -filter point \
		-distort SRT "0,0 1 0 0,0" +repage \
		\
		mpr:txt -compose CopyOpacity -composite \
	\) \
	-background black -alpha remove \
	+depth \
	-filter Cubic \
	-resize 2%x20% \
	-resize 1000%x100% -roll +0+0 \
	\( \
		\( xc:'#888' xc:'#FFF' xc:'#888' +append \) \
		\( xc:'#000' xc:'#888' xc:'#000' +append \) \
		-append -filter Cubic -resize $size\! -resize 20% \
	\) \
	-compose Multiply -composite \
	-auto-level \
	\
	text:- |
grep -i '#F' |
sort --field-separator='(' --key=2 -r |
grep -i '(' --max-count=1 |
cut -d ":" -f 1 |
while IFS="," read x y; do
	# echo "$x,$y"
	x2=$((5*$x-$fontsize*$flarewidth/2/256))
	y2=$((5*$y-$fontsize*$flareheight/2/256))
	# echo "+$x2+$y2"
	convert $outfile -gravity NorthWest \
		 \( +clone \
			\( $flarefile \
				-resize $((100*$fontsize/256))% \
				-set option:distort:viewport $size+0+0 \
				-virtual-pixel none \
				-distort SRT \
				"0,0 1 0 $x2,$y2" \
				-write mpr:flare \
				\) \
			-background none -compose Screen -composite \
		\) \
		+swap -compose CopyOpacity -composite \
		\
		\( mpr:flare -channel A -gamma 1.42 +channel \) \
		-compose DstOver -composite \
		\
		$outfile
done
	

