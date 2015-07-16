# Contact     : daweih@me.com
# Date        : 
# Last Update : 
# Reference   : 
# Description : 

#===============================================================================================================
use strict;
use warnings;

open I, "< rice_chr_lgth.txt";
my $chr_lgth;
my $index = 0;
while(<I>){
	chomp;
	my @r = split /\t/,$_;
	next if(/^Sequence.*/);
	$chr_lgth->{$r[0]}->{lgth} = $r[1];
	$chr_lgth->{$r[0]}->{idx} = $index;
	$index+=1;
}
close I;

open I, "< all.txt";
my $chr_info;
while(<I>){
	chomp;
	#1	21733010	Os01g0543200	C	T	Non-synonymous substitution	Hypothetical protein.
	#Chr	POS	SNPName	process	trait	chr_index	color	chr_lgth
	#1A	13.73	BS00033749_51	D		0	red	161
	my @r = split /\t/,$_;
#	print scalar(@r), "\n";
	next if(/^Chr.*/);
	my @rec;
	push @rec, $r[0];
	push @rec, $r[1];
	push @rec, $r[2];
	push @rec, $r[3]."->".$r[4];
	push @rec, $r[5];
	$_ = join "\t",@rec;
	@r = split /\t/,$_;
=cut
AC
AG
AT
CA
CG
CT
GA
GC
GT
TA
TC
TG
Met codon disrupted
Non-synonymous substitution
Premature
Splicing site disrupted
Stop codon disrupted

1	21733010	Os01g0543200	C->T	Non-synonymous substitution	0	gray	43270923
=cut	
	$_ .= "\t". $chr_lgth->{$r[0]}->{idx} ."\t";
	if($r[4] eq "Met codon disrupted"){
		$_ .= "darkred\t";
	}elsif($r[4] eq "Non-synonymous substitution"){
		$_ .= "black\t";
	}elsif($r[4] eq "Premature"){
		$_ .= "orange\t";
	}elsif($r[4] eq "Splicing site disrupted"){
		$_ .= "blue\t";
	}else{
		$_ .= "darkcyan\t";	
	}
	
	$_ .= $chr_lgth->{$r[0]}->{lgth} ."\n";
	
	$chr_info->{$r[0]} .= $_;

}
close I;
foreach my $chr_name (keys %{$chr_info}){
	print $chr_name, "\n";
	open O, "> $chr_name.txt";
	print O "Chr	POS	SNPName	process	trait	chr_index	color	chr_lgth\n";
	print O $chr_info->{$chr_name};
	close O;
	system "sort -n -k 2,2 $chr_name.txt > $chr_name.sort.txt";
}
__END__
