#
#	Text Effect
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
padding=20
# padding on top and bottom sides:
paddingV=0

# ( and the image size inside the paddings: )
IFS="x" read -a arr <<< "$size"
size2="$((${arr[0]}-2*$padding))x$((${arr[1]}-2*$paddingV))"


# Text parameters:
linespacing=$((-25*$fontsize/100))
# fontface='../fonts/DroidSerif-BoldItalic.ttf'
fontface='../fonts/texgyreschola-bolditalic.otf'


# image holding the pattern inside font:
patternfile='textEffect04/pattern02.png'

# colorize the pattern file:
patternshade=( '#0e2031' '#447698' '#98e2fc' )
color1='#949'
color2='#9ef'
color3='#FFF'

# stripe pattern around the font contours:
strokegradient='imgs/pattern01.png'
# controls the stroke colors:
# values 0…200, default 100,
# http://www.imagemagick.org/Usage/color_mods/#modulate_hue
strokehue=100

clutfile='textEffect04/hald_GL.png'


# Images file of the highlight flare:
#  	all the files 'star-*.png' in folder 'imgs'

# stars=`ls -1 textEffect04/star-9-*.png `
# numstars=`ls -1 textEffect04/star-*.png | wc -l `
# give 2nd file:
# star2=`ls -1 textEffect04/star-* | sed '2!d'`

flarefile=( )
numstars=0
for fname in $(ls -1 textEffect04/star-*.png)
do
    flarefile[$numstars]=$fname
    numstars=$((numstars+1))
done
#echo ${flarefile[*]}


# DropShadow, intensity: 1.0-normal .. 2.0-high:
dropshadowintensity=2



# OuterGlow, radiusxsigma+x+y:
#outerglow="$((36*$fontsize/256+1))x$((12*$fontsize/256+1))+0+0"
#outglowintensity=1.8

# radius for the stroke around the font:
stroke='5.0'
# ( and relatively to font size, min r=1.0 )
strokesize=`echo "scale=2; r=$stroke*$fontsize/256.0; if (r<1.0) 1.0 else r" | bc`



# Function for scaling relatively to font size, `sf 100` -> value scaled to font size
function sf {
echo `echo $(($1*$fontsize/256))`
}
function sfd {
echo `echo "scale=2; $1*$fontsize/256" | bc`
}


# Density of flares, in per cents,
#  relative to string length, 
# '70' meaning approx. 70 per cent of characters have a highlight 
flareratio=400
flarenum=$(($flareratio*${#label}/100))


# temporary text file for saving the highlight coordinates
txtfile='tmp_coordsXY.txt'

# downscaling factor for speeding up the highlight search:
# in per cents, suitable values 100,50,25,20,10,5,2,1 …
samplescale=25


# calculate the color transform for shading to hex colors:
# A: hex values to decimal 0…1
A=( 	`convert -size 1x1 xc:$color1 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.r]" info:` 
	`convert -size 1x1 xc:$color1 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.g]" info:` 
	`convert -size 1x1 xc:$color1 -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:$color2 -format "%[fx:u.b]" info:` 
	`convert -size 1x1 xc:$color3 -format "%[fx:u.b]" info:` )
	
# B inverse color matrix of image pattern01.png:
# inverse( magenta | cyan | white )
B=( 0.7466 -2.9482 2.2016 -1.6655 0.0383 1.6273 0.8081 1.8090 -1.6171 )

# matrix product A*B
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
      -interline-spacing `sf -60` \
      -kerning `sfd -3.0` \
    	-gravity $align \
    	caption:"$label" \
	\
	-gravity Center -extent $size \
	-write mpr:mask \
	\
	\( 	mpr:mask -background black -alpha remove \
            -virtual-pixel black \
		-filter Cubic -resize "$((2560/$fontsize))%" \
		-morphology Dilate Disk:1 \
            -distort SRT "0,0 1 0 0,`sfd 1`" \
            -resize $size\! -auto-level -gamma $dropshadowintensity -alpha shape \
            -function polynomial 0 \
            +repage \
	\) \
	\
	\(  $strokegradient \
		-roll "+0+$paddingV" +repage \
		-filter Cubic -resize "`sf 100`%" \
		-color-matrix "${AB[*]}" \
		-set option:distort:viewport $size+0+0 \
		-virtual-pixel Tile -filter point -distort SRT 0 +repage \
		\
		\( mpr:mask \
			-channel A \
			-morphology Dilate Disk:$strokesize +channel \
		\) \
		-compose CopyOpacity -composite \
	\) \
	\
    	\( 	mpr:mask -background black -alpha remove \
		+depth \
		\( +clone \
			-morphology Edge Square:1 \
			-negate -morphology Distance Euclidean:5 \
			-function polynomial $((16*256/fontsize)),0 \
		\) \
		-compose Mathematics -define compose:args='2,-1,0,0.5' \
		-composite \
		\
		-channel GB \
		-function polynomial `sfd 1.0`,0,0 \
		-virtual-pixel mirror \
		-bias 50% \
		-define convolve:scale=1 \
		\
		-channel G \
		-morphology Convolve "3x3:1,0,-1 2,0,-2 1,0,-1"  \
		\
		-channel B \
		-bias 50% \
		-define convolve:scale=1 \
		-morphology Convolve "3x3:1,2,1 0,0,0 -1,-2,-1" \
		\
		-channel RGB \
		-depth 8 \
		$clutfile -hald-clut \
		\( 	\( -size 1x1 xc:${patternshade[0]} \) \
			\( -size 1x1 xc:${patternshade[1]} \) \
			\( -size 1x1 xc:${patternshade[2]} \) \
			+append -filter Cubic \
			-resize 256x1\! \
		\) 	\
		-clut \
		\
		\( $patternfile -negate \
			-resize "`sf 100`%" \
			-function polynomial `sfd 0.125`,0 \
			-set option:distort:viewport $size+0+0 \
			-virtual-pixel Tile -filter point \
			-distort SRT "0" +repage \
		\) \
		+swap -compose Minus -composite \
        	mpr:mask  \
		-compose CopyOpacity -composite \
	       \
		+repage \
    	\) \
      \
	-gravity NorthWest \
	-delete 0 \
	-compose SrcOver -background none -flatten \
	-crop $size+0+0 +repage \
	\
	$infile -compose DstOver -composite \
	-write $outfile +delete \
    	\
    	\
	mpr:mask -background black -alpha remove \
	+depth -filter Cubic -resize 4% -resize $((2500*$samplescale/100))% \
	-function polynomial -4,4,0 \
 	\( +clone +noise Random \) \
 	-compose Multiply -composite \
 	-auto-level \
	-channel B -function polynomial 1,0 +channel \
text:- |
grep -i '#F' |
sort --field-separator='(' --key=2 -r |
grep -i ',' --max-count=$flarenum |
cut -d "#" -f 1 |
sed -e 's/(//g' | sed -e 's/)//g' |
sed -e 's/:/,/g' |
cut -d "," -f 1,2,4 >$txtfile

# code above writes image to a text file first in format:
#  26,1: (  204,  115,   20,65535)  #00CC00730014  srgba(0.31%,0.17%,0.030%,1)
# It sorts the entries by the red value, chooses $flarenum largest ones and picks x, y and blue values to format:
#  26,1,20
# This gives coordinates x and y and a relative scaling% for each highlight star


( STR="" &&
while IFS=',' read x y r; do
r2=$(($r%$numstars))
STR="${STR}
    push graphic-context
    translate $(($x*100/$samplescale-`sf 32`)),$(($y*100/$samplescale-`sf 32`))
    scale `sfd 1.5`,`sfd 1.5`
    image over 0,0 0,0 '${flarefile[$r2]}'
    pop graphic-context"
done &&
convert -size $size xc:none \
    -draw "$STR" \
    -negate \
    -channel A -blur "1x0.3" -function polynomial 1,0 +channel \
    \
    $outfile \
    +swap -background none -flatten $outfile
) <$txtfile

