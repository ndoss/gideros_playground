#!/usr/bin/perl
use strict;

#==============================================================================
sub trim($) {
  my $text = shift;
  $text =~ s/^\s+//; # trim leading whitespace
  $text =~ s/\s+$//; # trim trailing whitespace  
  return $text;
}

#==============================================================================
sub parsePhoneme
{
    my ($in,$out)  = @_;
    my $line = trim(<$in>);
    $line =~ m/(\d+)\s+(\S+)/;

    printf($out "               phoneme='%s';\n", $2);
    printf($out "               startFrame=%s;\n", $1);
}

#==============================================================================
sub parseWord
{
    my ($in,$out,$beginPhrase, $endPhrase)  = @_;

    my $line = <$in>;
    $line =~ m/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)/;
    printf($out "            text='%s';\n", $1);    
    printf($out "            frames = { %d, %d };\n", $2, $3);
    for (my $i=0; $i<$4; ++$i)
    {
        printf($out "            {\n");
        parsePhoneme($in,$out);
        printf($out "            },\n");
    }
}


#==============================================================================
sub parsePhrase
{
    my ($in,$out)  = @_;

    printf($out "         text='%s';\n", trim(<$in>));
    my $begin = trim(<$in>);
    my $end  = trim(<$in>);
    printf($out "         frames = { %d, %d };\n", $begin, $end);
    
    my $count = trim(<$in>);
    for (my $i=0; $i<$count; ++$i)
    {
        printf($out "         {\n");
        parseWord($in, $out, $begin, $end);
        printf($out "         },\n");
    }
}

#==============================================================================
sub parseVoice
{
    my ($in,$out)  = @_;
 
    printf($out "      voiceName='%s';\n", trim(<$in>));
    printf($out "      text='%s';\n", trim(<$in>));

    my $count     = trim(<$in>);
    for (my $i=0; $i<$count; ++$i)
    {
        printf($out "      {\n");
        parsePhrase($in, $out);
        printf($out "      },\n");
    }
}

#==============================================================================
sub parseVoices
{
    my ($in,$out)  = @_;

    my $count = trim(<$in>);
    for(my $i=0; $i<$count; ++$i)
    {
        printf($out "   {\n");
        parseVoice($in,$out);
        printf($out "   },\n");
    }
}

#==============================================================================
sub parseHeader
{
    my ($in,$out)  = @_;

    printf($out "   version='%s';\n", trim(<$in>));
    printf($out "   audioFile='%s';\n", trim(<$in>));
    printf($out "   frameRate=%d;\n", trim(<$in>));
    printf($out "   framesInFile=%d;\n", trim(<$in>));
}

#==============================================================================
foreach my $in (@ARGV)
{
    # Create output file name
    my $out = $in;
    $out =~ s/.pgo/.lst/;

    # Open files
    print("* Parsing $in\n");
    open(IN, "<$in")   || die "Unable to open input file: $in\n";
    open(OUT, ">$out") || die "Unable to open output file: $out\n";

    # Print start line for lua file
    print(OUT "return {\n");

    # Parse the file
    parseHeader(\*IN, \*OUT);
    parseVoices(\*IN,\*OUT);

    # Close out lua file
    print(OUT "}");

    # Close files
    close(IN);
    close(OUT);
}
