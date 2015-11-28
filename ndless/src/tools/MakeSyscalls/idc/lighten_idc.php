#!/usr/bin/php -f
<?php
$input = fopen($argv[1], "r");
$input || die("Couldn't open input.");
$output = fopen($argv[2], "w");
$output || die("Couldn't open output.");

$head = <<<EOF
#define UNLOADED_FILE   1
#include <idc.idc>

static main(void)
{

EOF;
fwrite($output, $head);

$last_line = "";
while(($line = fgets($input)) !== FALSE)
{
	if(strpos($line, "MakeName") === FALSE)
	{
		$last_line = $line;
		continue;
	}

	//Skip string definitions and other unneeded names
	if(strpos($last_line, "MakeStr") !== FALSE || strpos($line, "\"null") !== FALSE || strpos($line, "j_") !== FALSE)
	{
		$last_line = $line;
		continue;
	}

	fwrite($output, $line);
	
	$last_line = $line;
}

fwrite($output, "}");

fclose($output);
?>
