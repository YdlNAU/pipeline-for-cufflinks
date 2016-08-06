#! /usr/bin/perl
## Author: yudalang
## Date: 2016/08/05
## contact: 346871663@qq.com
## description:See github
use warnings;
use strict;
use Cwd qw(cwd);

open(RESULT,">result.txt");
select(RESULT);#设置output为result.tet

print cwd, "\t This is the current working dir!\n";

print "##Following files are in this dir:\n";
opendir FILE,'.' or die "unsucceed!";
my @fileNames;
while(my $name=readdir FILE){
	next if $name=~/^\./;#如果想要所有的非点（non-dot）文件(不是由点开头的文件)
	print "$name\n";
	push @fileNames,$name;
}
closedir FILE;

my $loop_flag;
foreach my $fileName(@fileNames){
	next unless (-d $fileName);
	$loop_flag++;
	chdir("$fileName");
	print STDOUT "$fileName\n";
	print cwd, "\t This is the current working dir!Loop $loop_flag\n";
	
	#you can do some thing!#/gpfs1/jobdata/dlyu/Ref
	my $outfileName=$fileName."Cuffl";
	print STDOUT "Now we do the system call!\n";
	my $state_flag=system("cufflinks -G /gpfs1/jobdata/dlyu/Ref/genome.gtf -b /gpfs1/jobdata/dlyu/Ref/genome.fasta -p 15 -u -o $outfileName accepted_hits.bam 2>error");
	#statement:正确的话，应该是readpipe("") or die "error :$?";但是程序执行完后
	die "error :$?" unless $state_flag==0;
	
	chdir("..");#回到最开始目录
	
	open IN,"./$fileName/$outfileName/genes.fpkm_tracking" or die "$!";
	open OUT,">$outfileName.csv";
		while (<IN>){
			chomp;
			my @arr=split /\s+/,$_;
			print OUT "$arr[0],$arr[9]\n";
			
		}
	close IN;close OUT;
	
	$state_flag=system("mv ./$fileName/$outfileName /gpfs1/jobdata/dlyu/fpkmStore/;rm -r $fileName");
	die "error :$?" unless $state_flag==0;
	
	print "\n",cwd, "\t This is the current working dir.Now we return to the primary dir!\n";
}







close(RESULT);

