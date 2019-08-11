#
#	Image Effect
#	Espoo, Finland, September 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 

w=`convert $infile -format %w info:`

#	edge width as a fraction of image width, e.g 1/200 of width
edgewidth='180'

# blur parameters by edgewidth:
bradius=`echo "scale=5;${w}/$edgewidth" | bc -l`
bsigma=`echo "scale=5;${w}*0.3333/$edgewidth" | bc -l`
edgeblur="${bradius}x${bsigma}"


# values between 0...200
brightness='100'
saturation='120'


#	controls the amount of edges added to output:
effectStrength='18.0'

# converting to bw:
colmat="3 5 1 0"


convert $infile \
	\
	\( +clone -function polynomial -1,2,0 \) \
	\
	\( -clone 0 \
		\( +clone -gamma 1.6 \
			-blur $edgeblur \
			-function polynomial 1.2,0 \
				\( +clone -blur $edgeblur \) \
				-compose Minus -composite \
			-color-matrix "$colmat $colmat $colmat 0 0 0 1" \
			-function polynomial -$effectStrength,1 \
			-level 60%,90% \
		\) -compose Multiply -composite \
		\
		-gamma 2.0 \
	\) \
	-delete 0 \
	-compose blend -define compose:args=50,50 -composite \
	-modulate $brightness,$saturation \
	$outfile
