#	Image Effect 
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1
outfile=$2


# controls for the final output :
saturation=100

# values between -100...100
# '-8,13'
brightness=-8
contrast=13

convert $infile \
	-channel R -function polynomial 45.7748,-90.0267,57.3378,-11.1184,0.8729,0.0712 \
	-channel G -function polynomial 59.5145,-92.8527,39.8515,-0.392,-0.443,0.1436 \
	-channel B -function polynomial -13.0749,24.0632,-11.3575,-0.0044,1.0775,0.4416 \
	-channel RGB -function polynomial 1.1192,-3.6326,3.9,-0.4923,0.1059 \
	-brightness-contrast $brightness,$contrast \
	-modulate 100,$saturation \
	$outfile
