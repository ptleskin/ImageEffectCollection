#!/bin/bash

#	Linear Blur Effect
#	Espoo, Finland, August 2019
#	Petri Leskinen, petri.leskinen@icloud.com
#	
#	My HTML5-version: https://pixelero.wordpress.com/2014/12/15/linear-and-radial-blur-with-html5/
#	
#	bash [options] input_image control_points output_image
#	options:
#	-b	blur radius in perpendicular direction at the second control point,
#		default: 16
#	-c	blur radius in parallel direction
#		default: same as first radius
#	-m	mode: 'linear' (default) or 'radial'
#
#	-x 	mixing: 'blend' (default), 'Lighten', or 'Darken' are recommended. 
#				Generally can be any of ImageMagick blending methods 
#				(http://www.imagemagick.org/Usage/compose/)
#
#	for example:
#
#	radial blur with focal point:
#	bash linearBlur.bash -b 12 -c 1 -m 'radial' input.jpg "160,175 300,175" output.jpg
#
#	zoom effect:
#	bash linearBlur.bash -b 1 -c 12 -m 'radial' input.jpg "160,175 300,175" output.jpg
#
#	horizontal blurring:
#	bash linearBlur.bash -b 1 -c 12 input.jpg "160,175 300,175" output.jpg
#
#	vertical blurring:
#	bash linearBlur.bash -b 12 -c 1 input.jpg "160,175 300,175" output.jpg
#


blur="16"
mode="linear"
blend="blend"

while getopts "b:c:m:x:" option
do
	case "${option}"
		in
		b) blur=${OPTARG};;
		
		c) blur2=${OPTARG};;
		
		m) mode=${OPTARG};;
		
		x) blend=${OPTARG};;
		
	esac
done

shift $((OPTIND-1))

if [ -z "$blur2" ]
  then
    #	echo "Using same blue value in both the directions"
	blur2=$blur
fi

#	Locations of input and output images:
infile=$1
outfile=$3

#	control points, in format 'X,Y X2,Y2' e.g. '100,100 250,100'
coords=$2

#	controls attenuation of the blur
f="0.5"

IFS=', ' read -r -a array <<< "$coords"

p0x="${array[0]}"
p0y="${array[1]}"
p1x="${array[2]}"
p1y="${array[3]}"

#	difference of control points
d2x=$(bc <<< "scale=5;$p1x-$p0x")
d2y=$(bc <<< "scale=5;$p1y-$p0y")

d1x=$(bc <<< "scale=5;-$d2y")
d1y=$(bc <<< "scale=5;$d2x")

#	a point perpendicular to line (p0,p1), at the distance |p1-p0| from p0
p2x=$(bc <<< "scale=5;$p0x+$d1x")
p2y=$(bc <<< "scale=5;$p0y+$d1y")

#	distance of control points
r=$(bc <<< "scale=5;sqrt($d2x*$d2x+$d2y*$d2y)")

#	unit vector perpendicular to (p0,p1)
d1x=$(bc <<< "scale=5;$d1x/$r")
d1y=$(bc <<< "scale=5;$d1y/$r")

#	unit vector parallel to (p0,p1)
d2x=$(bc <<< "scale=5;$d2x/$r")
d2y=$(bc <<< "scale=5;$d2y/$r")

#	controls when iterations stop
limit="0.5"

cm=""

if [ $mode == "radial" ]
then
	#	RADIAL BLUR
	while [ "$(bc <<< "$blur > $limit")" == "1" ] ||  [ "$(bc <<< "$blur2 > $limit")" == "1" ]
	do
		 if [ "$(bc <<< "$blur > $limit")" == "1" ]
		 then
		 	
		 	#	apply the desired CCW rotation around p0
			theta=$(bc <<< "scale=8;$blur/$r")
			cs=$(bc -l <<< "scale=8;c($theta)")
			sn=$(bc -l <<< "scale=8;s($theta)")
			
			pXx=$(bc <<< "scale=5;$p0x+$cs*($p1x-$p0x)-$sn*($p1y-$p0y)")
			pXy=$(bc <<< "scale=5;$p0y+$sn*($p1x-$p0x)+$cs*($p1y-$p0y)")
			
			pYx=$(bc <<< "scale=5;$p0x+$cs*($p2x-$p0x)-$sn*($p2y-$p0y)")
			pYy=$(bc <<< "scale=5;$p0y+$sn*($p2x-$p0x)+$cs*($p2y-$p0y)")
			
			
			cm+="-write mpr:tmp "
			
			#	original image rotated CCW by angle theta:
			cm+="( ( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$pXx,$pXy,$p2x,$p2y,$pYx,$pYy ) " 
			
			#	apply same rotation to reverse CW direction,
			#	only sine terms change sign:
			pXx=$(bc <<< "scale=5;$p0x+$cs*($p1x-$p0x)+$sn*($p1y-$p0y)")
			pXy=$(bc <<< "scale=5;$p0y-$sn*($p1x-$p0x)+$cs*($p1y-$p0y)")
			
			pYx=$(bc <<< "scale=5;$p0x+$cs*($p2x-$p0x)+$sn*($p2y-$p0y)")
			pYy=$(bc <<< "scale=5;$p0y-$sn*($p2x-$p0x)+$cs*($p2y-$p0y)")
			
			#	original image rotated CW by angle theta:
			cm+="( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$pXx,$pXy,$p2x,$p2y,$pYx,$pYy ) " 
			
			#	mix the two rotated images
			cm+="-compose $blend -define compose:args=50,50 -composite ) "
			
			#	blend with source image
			cm+="-compose blend -define compose:args=50,50 -composite "
			
			#	decrease the blur amount
			blur=$(bc <<< "scale=5;$blur*$f")
		fi
		
		if [ "$(bc <<< "$blur2 > $limit")" == "1" ]
		 then
		 	
		 	#	blur outwards in the direction of radius:
			d=$(bc <<< "scale=8;($r+$blur2)/$r")
			pXx=$(bc <<< "scale=5;$p0x+$d*($p1x-$p0x)")
			pXy=$(bc <<< "scale=5;$p0y+$d*($p1y-$p0y)")
			
			pYx=$(bc <<< "scale=5;$p0x+$d*($p2x-$p0x)")
			pYy=$(bc <<< "scale=5;$p0y+$d*($p2y-$p0y)")
			
			
			cm+="-write mpr:tmp "
			cm+="( ( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$pXx,$pXy,$p2x,$p2y,$pYx,$pYy ) " 
			
			
			#	blur inwards in the direction of radius:
			d=$(bc <<< "scale=8;($r-$blur2)/$r")
			pXx=$(bc <<< "scale=5;$p0x+$d*($p1x-$p0x)")
			pXy=$(bc <<< "scale=5;$p0y+$d*($p1y-$p0y)")
			
			pYx=$(bc <<< "scale=5;$p0x+$d*($p2x-$p0x)")
			pYy=$(bc <<< "scale=5;$p0y+$d*($p2y-$p0y)")
			
			cm+="( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$pXx,$pXy,$p2x,$p2y,$pYx,$pYy ) " 
			
			cm+="-compose $blend -define compose:args=50,50 -composite ) "
			cm+="-compose blend -define compose:args=50,50 -composite "
			
			blur2=$(bc <<< "scale=5;$blur2*$f")
		fi
	done
	
else

	#	LINEAR BLUR
	while [ "$(bc <<< "$blur > $limit")" == "1" ] ||  [ "$(bc <<< "$blur2 > $limit")" == "1" ]
	do
		 if [ "$(bc <<< "$blur > $limit")" == "1" ]
		 then
		 	
			pXx=$(bc <<< "scale=5;$p2x+$blur*$d1x")
			pXy=$(bc <<< "scale=5;$p2y+$blur*$d1y")
			cm+="-write mpr:tmp "
			cm+="( ( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$p1x,$p1y,$p2x,$p2y,$pXx,$pXy ) " 
			
			pXx=$(bc <<< "scale=5;$p2x-$blur*$d1x")
			pXy=$(bc <<< "scale=5;$p2y-$blur*$d1y")
			cm+="( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$p1x,$p1y,$p2x,$p2y,$pXx,$pXy ) " 
			
			cm+="-compose $blend -define compose:args=50,50 -composite ) "
			cm+="-compose blend -define compose:args=50,50 -composite "
			
			blur=$(bc <<< "scale=5;$blur*$f") 
		fi
		
		if [ "$(bc <<< "$blur2 > $limit")" == "1" ]
		 then
		 	
			pXx=$(bc <<< "scale=5;$p2x+$blur2*$d2x")
			pXy=$(bc <<< "scale=5;$p2y+$blur2*$d2y")
			
			cm+="-write mpr:tmp "
			cm+="( ( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$p1x,$p1y,$p2x,$p2y,$pXx,$pXy ) " 
			
			pXx=$(bc <<< "scale=5;$p2x-$blur2*$d2x")
			pXy=$(bc <<< "scale=5;$p2y-$blur2*$d2y")
			cm+="( mpr:tmp -distort Affine $p0x,$p0y,$p0x,$p0y,$p1x,$p1y,$p1x,$p1y,$p2x,$p2y,$pXx,$pXy ) " 
			
			cm+="-compose $blend -define compose:args=50,50 -composite ) "
			cm+="-compose blend -define compose:args=50,50 -composite "
			
			blur2=$(bc <<< "scale=5;$blur2*$f")
		fi
	done
fi

convert ${infile} $cm ${outfile}

