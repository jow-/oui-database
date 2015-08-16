#!/usr/bin/env perl

use strict;
use JSON;

if (open DB, "wget -O- 'https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf' |")
{
	my @output;

	while (defined(my $line = readline DB)) {
		chomp $line;

		next if ($line =~ m!\[TR\?\]! || $line =~ m!Please see MAM public listing for more information!);

		if ($line =~ m!
			^
				([0-9A-F]{2}(?:[:-][0-9A-F]{2}){2,5})
				(?:/([0-9]{1,2}))?
				\t (\S+)
				(?: \s+ \# \s (.+))?
			$
		!x) {
			my ($prefix, $mask, $company, $comment) = ($1, $2, $3, $4);

			$prefix =~ s/[:-]//g;
			$mask = length($prefix) * 4 unless defined $mask;

			$prefix .= ('0' x (12 - length($prefix)));
			$prefix =~ s/^0+([0-9A-F])/$1/g;

			push @output,
				$prefix,
				$mask,
				$comment || $company;
		}			
	}

	close DB;

	if (open JSON, "> oui.json")
	{
		print JSON encode_json(\@output);
		close JSON;
	}
}
