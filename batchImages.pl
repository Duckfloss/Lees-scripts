#	BATCH IMAGE PROCESSOR FOR Lee'sAdventureSports.com
#
#	This fantastic little script takes all the image files
#	in one folder (see $source) and hacks 'em up into:
#		* x_lg.jpg (1050px/1050px)
#		* x_med.jpg (350px/350px)
#		* x_t.jpg (100px/100px)
#		* x_sw.jpg (350px/350px)**
#	saved in another folder (see $dest)
#	
#	**the swatch has to be manually chopped down to 25x25px
#	requires ImageMagick and PerlMagick be installed


use strict;
use warnings;
use Image::Magick;			
use File::Basename;

my $source = "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets";
my $dest = "R:/RETAIL/IMAGES/4Web";
my $dir = $source;
my @files;
my $lg = 1050;
my $med = 350;
my $t = 100;
my $sw = 25;

main();

sub main {

	opendir DIR, $dir or die "cannot open dir $dir: $!";
	@files = grep { $_ =~ /.jpg/ || /.png/ || /.jpeg/ || /.gif/ } readdir DIR;
	closedir DIR;

	foreach(@files) {
		my($image, $x);

		#prepend full path for file
		my $path = $dir."/".$_;
		#get filename sans extension
		my $fh = fileparse($_, qr/\.[^.]*/);

		#open file
		$image = Image::Magick->new;
		$x = $image->Read($path);

		#set to 72ppi resolution
		$x = $image->Set(density=>'72x72');
		warn "$x" if "$x";
		
		#set color profile to RGB
		$x = $image->Quantize(colorspace=>'RGB');
		warn "$x" if "$x";

		#get width/height, ratio and reverse-ratio
		my $ww = $image->Get('width');
		my $hh = $image->Get('height');
		my $ratio = $ww/$hh;
		my $rratio = $hh/$ww;

		if( $ratio < 1 ) {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
			$x = $image->Extent(geometry=>$lg."x".$lg, gravity=>"Center", background=>"#ffffff");
			warn "$x" if "$x";
		} elsif ( $ratio > 1 ) {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
			$x = $image->Extent(geometry=>$lg."x".$lg, gravity=>"Center", background=>"#ffffff");
			warn "$x" if "$x";
		} else {
			$x = $image->Sample(geometry=>$lg."x".$lg);
			warn "$x" if "$x";
		}

		#save large
		$x = $image->Write("$dest/$fh\_lg.jpg");
		warn "$x" if "$x";

		#save medium
		$x = $image->Resize(geometry=>$med."x".$med);
		warn "$x" if "$x";
		$x = $image->Write("$dest/$fh\_med.jpg");
		warn "$x" if "$x";
		#outputs something we can manually make into a swatch
		$x = $image->Write("$dest/$fh\_sw.jpg");
		warn "$x" if "$x";

		#save thumbnail
		$x = $image->Sample(geometry=>$t."x".$t);
		warn "$x" if "$x";
		$x = $image->Write("$dest/$fh\_t.jpg");
		warn "$x" if "$x";
	}
}

