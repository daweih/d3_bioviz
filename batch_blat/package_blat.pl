?# Contact     : daweimhuang@gmail.com
# Date        : Sun Aug 14 13:52:45 AST 2011 by huangdw
# Last Update : Mon Aug 15 12:02:45 AST 2011 by huangdw
# Reference   : 
#
# Description : ??????blat??????login????????

#===============================================================================================================
#use lib "/opt/perl5.12.3/lib/site_perl/5.12.3";
#use Bio::Perl;

use warnings;
use strict;
use Getopt::Long;

my %opts;
GetOptions(\%opts,"database:s","quary:s","packageCount:s","qrna:s");
my $usage= <<"USAGE";
	Program: $0
	INPUT:
		-database			full path of blat database
		-quary				full path of blat quary
		-packageCount		the piece count u need for the data to be split
		-qrna				optional, +
	EXAMPLE:
		perl package_blat.pl	-database /lustre/share/qatar_DP_v3/PdactyKAsm30_r20101206.fasta -quary ../PDK30-mrna.fsa -packageCount 5
	OUTPUT:
		
USAGE
die $usage unless ($opts{database});
die $usage unless ($opts{quary});
die $usage unless ($opts{packageCount});

my $startTime=localtime();
################################ Main ##########################################################################

#make soft link
system "ln -fs $opts{database} database.fa";
system "ln -fs $opts{quary} quary.fa";
print "Done make link.\n";

#make 11.ooc
system "blat database.fa quary.fa ooc.psl -makeOoc=11.ooc";
print "Done make 11.ooc.\n";

#split quary into packages
open I, "< quary.fa";
my $key;
my %seq;
while(<I>)
{
	if(/>.*/)
	{
		$key = $_;
	}
	else
	{
		$seq{$key} .= $_;
	}
}

my @key = keys(%seq);
#342964

my $packageNo = 1;
my $packageRecordCount = 0;
my $packageRecordCountCutoff = int(($#key + 1) / ($opts{packageCount} - 1));
my @packageNames;
foreach $key (sort keys %seq)
{
	open O, ">> package_$packageNo\.fa";
	push(@packageNames, "package_$packageNo\.fa");
	print O "$key$seq{$key}";
	$packageRecordCount += 1;
	if($packageRecordCount == $packageRecordCountCutoff)
	{
		$packageNo += 1;
		$packageRecordCount = 0;
	}	
}
#print "Done split quary into $opts{packageCount} packages.\n";
@packageNames = &Uniq(@packageNames);
#print "\nStarting writing shell...\n";

#write shell and qsub them
my $path = `pwd`;
chomp($path);

my %jobId;#??????????????????????????qsub, run, finished
foreach(0..$#packageNames)
{
	my $no = $_ + 1;
	open SH, "> blat_$no.sh\n";
	
	print SH "#/opt/biosoft/bin/\n";
	print SH "#!/bin/sh\n";
	print SH "#PBS -N $packageNames[$_]\n";
	print SH "#PBS -o blat_$no.qsub.out\n";
	print SH "#PBS -e blat_$no.qsub.err\n";
	print SH "#PBS -q bioqueue\n";
#	print SH "#PBS -d /lustre/huangdw/sh\n";
	print SH "#PBS -l nodes=1:ppn=3\n";
	my $blatCmd = "blat $path/database.fa $path/$packageNames[$_] $path/$packageNames[$_].psl -ooc=$path/11.ooc -noHead";
	$blatCmd .= " -fine -q=rna" if(defined $opts{qrna});
	$blatCmd .= "\n";
	print SH $blatCmd;
	
	my $jobId = `qsub blat_$no.sh`;
	print "$jobId";#682539.mu01
	chomp($jobId);
	if($jobId =~ /^\d+\.mu01$/)
	{
		$jobId{qsub}{$jobId} = "+";	
	}
	#	print "Done writing blat_$no.sh.\n";#	print "Done qsub blat_$no.sh.\n";
}
print "Done qsub.\n";

#watch the qstat list and cat all the files after every task is finished
my $finishedPackageCount = 0;
while($finishedPackageCount < $opts{packageCount})
{
	#679775.mu01               package_22.fa    huangdw         05:48:02 R bioqueue       
	my %runningJobId;#running package list, renew every 10s
	my $qstatInfo = `qstat| awk '/huangdw/{print }'`;
	my @qstatInfo = split /\n/,$qstatInfo;
	foreach(@qstatInfo)
	{
		my @r = split /\s+/,$_;
		if(defined $jobId{qsub}{$r[0]})
		{
			$runningJobId{$r[0]} = "+" if($r[4] ne "C");
			$jobId{run}{$r[0]}   = "+" if($r[4] eq "R" || $r[4] eq "C");
		}
	}
	my @runJobId = keys(%{$jobId{run}});
	if(($#runJobId + 1) == $opts{packageCount})#start to check finish job when all packages got the run tag
	{
		foreach my $jobId (sort keys %{$jobId{qsub}})
		{
			print "Finish package $jobId\n" if(defined $jobId{qsub}{$jobId} and defined $jobId{run}{$jobId} and !defined $runningJobId{$jobId} and !defined $jobId{finished}{$jobId});
			$jobId{finished}{$jobId} = "+" if(defined $jobId{qsub}{$jobId} and defined $jobId{run}{$jobId} and !defined $runningJobId{$jobId});
		}
	}
	my @finishedJobId = keys(%{$jobId{finished}});
	$finishedPackageCount = $#finishedJobId + 1;
	sleep 10;
}

my $err = `cat *err`;
if($err eq "")
{
	print "Finish All $opts{packageCount} Packages!\n";
}
else
{
	print "ERROR!\n";
	$err = `ll *err`;
	my @err = split /\n/,$err;
	foreach(@err)
	{
		my @r = split /\s+/,$_;
		#-rw------- 1 huangdw dpg 0 Aug 15 22:28 blat_10.qsub.err
		#0          1 2       3   4 5   6  7     8
		print "\t$r[8]\n" if($r[4] > 0);
	}
}

################################ Main ##########################################################################
#===============================================================================================================
my $options="-database $opts{database} -quary $opts{quary} -packageCount $opts{packageCount}";
   $options .= "-qrna $opts{qrna}" if(defined $opts{qrna});
my $endTime=localtime();
my $Program = $1 if($0 =~ /(.*)\.pl/);
open  LOG,">>$Program\_ProgramRunning\_Log";
print LOG "From \<$startTime\> to \<$endTime\>\tperl $0 $options\n";
close LOG;


################################ subroutines ###################################################################
	sub Uniq{
		my @strings = @_;
		my %hash;
		foreach(@strings){
			$hash{$_} += 1;
		}
		my @uniq = keys(%hash);
		return @uniq;
	}

__END__

for i in `qstat | awk -F'.' '!/-|Job/{print $1}'`; do qdel $i; done

pbsnodes -a

head -2000 /lustre/huangdw/Phoenix_dactylifera/annotation_genome/scaffolding/cdna/8tctg_final.fna>test.fa


nohup perl ../../../insideGap_filled_aug15/BIN_cDNABasedScaffolding/package_blat.pl -database /lustre/huangdw/Phoenix_dactylifera/annotation_genome/scaffolding/InsideGap_filled/BLAT/Test/test.fa -quary /lustre/huangdw/Phoenix_dactylifera/annotation_genome/scaffolding/InsideGap_filled/BLAT/Test/test.fa  -packageCount 29 > package_blat_log &
