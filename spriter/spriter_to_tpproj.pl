#!/usr/bin/perl
my @files = `find . -name "*.png"`;
print("<library>\n");
print(" <properties forceSquare=\"0\" alphaThreshold=\"0\" extrude=\"0\" padding=\"1\" showUnusedAreas=\"0\" removeAlphaBorder=\"0\"/>\n");
my %folders; 
my $firstFolder = 1;
foreach (@files) 
{
    chop();
    my ($dot, $dir, $file) = split('\/');
    if (! $folders{$dir}) 
    {
        if (! $firstFolder) { printf(" </folder>\n"); }
        print(" <folder name=\"$dir\">\n");
    }
    printf("  <file file=\"$dir/$file\"/>\n");
    $folders{$dir} = 1;
    $firstFolder   = 0;
}
printf(" </folder>\n");
printf("</library>\n");



