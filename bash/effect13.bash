#	Image Effect
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 


#	Required Hald color tables:
#	 effect13_hald.png:
#		Color Balance and Brightness/Contrast 
#		at the beginning of the Photoshop action
haldfile='effect13_hald.png'

#	Size of input image, in format "%wx%h"
w=`convert $infile -format %w info:`
h=`convert $infile -format %h info:`
size=`convert $infile -format %G info:`


# Vignetting at edges
# Note: reversed values: dark:'#FFF', light:'#000'
vignette='#888'


# value between -100...100
brightness=0
contrast=0



convert \( \( 	$infile ${haldfile} -hald-clut \
		\( +clone -modulate 100,0 -blur 0x20 +negate \
			-alpha Set -channel A -function polynomial 0.73 \
			-channel RGB \
		\) \
		-compose Overlay -composite \
		-modulate 100,110 \
	\) \
	\( +clone -modulate 100,80 \
		\( -clone 0 \
			\( -clone 0 -colors 16 -colors 1 \
				-colorspace HSL \
				-channel Lightness -function polynomial 0,0.4 \
				-channel Saturation -function polynomial 0,0.5 \
				-channel Hue,Saturation,Lightness \
				-colorspace RGB \
			\) \
			\( -clone 0 -modulate 100,0 -auto-level \
				-function polynomial 1,-0.1 \
			\) \
			-delete 0 \
			-compose Overlay -composite \
			-alpha Set -channel A -function polynomial 0.35 \
		\) \
		-compose Over -composite \
	\) \
	-delete 0 \
	-channel RGB \
	-brightness-contrast '9,16' \
	\( -size ${size} -resize 10% xc:'#000' \
		-background $vignette -virtual-pixel background \
		-blur 16x8 \
		-resize ${size}! \
	\) \
	-compose Minus_Src -composite \
	\) -brightness-contrast $brightness,$contrast \
	$outfile


# Inner Glow
# original background '#AFAFAF'




