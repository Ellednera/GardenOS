#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use File::Path qw(remove_tree); # consider this module
use Cwd "getcwd";
use File::Basename "basename";

# valcom.pl : validate command
# this will be all function calls for testing
# only testing one command at the moment: grow branch

# worst case scenario, but we're doing the easy way first :)
# our $cmd = "create branch 'oyster bed'"; 
# our $command = "grow branch";
our $command = "break  branch hello";
# our $branch = "...";
our $branch = "493";
our $leaf = "a.txt, ert.pp";
# execute
# {
# local $@;
# eval {	grow_branch($command)	};
# eval {	break_branch($command)	}; # done
# print $@ if $@;
# }
# &break_branch_force();
# say "Done";

# &parse($command);
# grow_leaf();
# &nip_leaf($leaf);
# &visit();

# say getcwd();
# chdir "DETAIls";
# say getcwd();

# &leave();
# &grow_leaves();
# &nip_leaf_all();
# &nip_leaf_some();
&banner();

# if we are making it as input and do stf pattern, it's very easy
# but command line pattern is more complex
# maybe do the simple pattern for the moment :)

# must use die, not warn, if not, then redo

# I think the easy way doesn't need much checking :|

# COMPLETE
sub grow_branch {
	say "Command detected: $command";
	say "Enter branch name: $branch"; 
	# for the branch name, uc or lc there are the same, R and r is the same folder
	die "You are not allowed to grow this branch!".
		"\nReason: Branch name can't start with '.'\n"
		if $branch =~ /\A\.+/; # don't allow . and .. to be deleted, dangerous
	# sleep 3;
	say "You are about to grow '$branch' branch, are you sure? (y/n) y";
	if ("y") {
		say "Creating branch . . .";
		mkdir "./$branch", 0777
			or die "Oops~ The branch '$branch' broke during the growing process.\nReason: $!\n";
		say "'$branch' branch has grown, yeah~";
	}
	
}
# still the easy way
# COMPLETE
sub break_branch {
	say "Command detected: $command";
	say "Break which branch? $branch";
	die "You are not allowed to break this branch!".
		"\nReason: Breaking this branch might \Udestroy\E your computer\n"
		if $branch =~ /\A\.+/; # don't allow . and .. to be deleted, dangerous
	# need to limit the naming style at the grow banch part

	say "The broken branch will be burned to ashes, are you sure? (y/n) y";
	if ("y") {
		say "Oh, well. Breaking '$branch' and burning it . . .";
		# sleep 3;
		rmdir "./$branch"
			or die "Oops~ The branch '$branch' couldn't be broken.\nReason: $!\n";
		# the system error message is still can be understood easily
		# but not for the grow_branch part
		say "'$branch' branch was broken and burned, ouch~";
	}
	
}

# will need the below below subroutine to extract the options~
# nope~ We'll use the File::Path module
sub break_branch_force {
	# my $error;
	eval {
		remove_tree("./oysters") or die "$!\n";
		# the official error handling using the ref doesn't work
	};
	print "$@" if $@;

}

# parser
sub flag_parser {
	my $command = shift;
	
	# break by space
	# don't split by one whitespace, it will cause an empty gap if there are more spaces
	
	# say join "|", split /\s+/, $command; # split all spaces
	# if more than 1 space, the validator will treat the space as invalid command
	# say scalar split /\s+/, $command;
	
	my @parts = split /\s+/, $command;
	
	# check all the broken parts
	# use a tree-like structure to do it
	# eg nexted if-else statement
	if ($parts[0] eq "break") {
		say "Found break, what's next?";
		if ($parts[1] eq "branch") {
			say "The command is $parts[0] $parts[1]";
			say "Command is valid";
		} elsif ($parts[1] eq "erm") {
			say "Unimplemented command part: erm";
		} else {
			say "Invalid command $command";
		}
	} elsif ($parts[0] eq "something") {
		say "Unimplemented command part"
	} else {
		say "'$command' is not recognised";
	}
	
	# do something
	
}

# create a file
# into the eval block too
sub grow_leaf {
	say "Your leaf name must include an extension if possible. ",
		"If not, you can still add the extension for the leaf name at some other time.";
	print "Name of leaf: ";
	chomp (my $filename = <STDIN>);
	# filenames can start with a "." but not directories
	open my $new_fh, ">:utf8", $filename
		or die "Oops~ Something went wrong with the leaf '$filename'.\nReason: $!";
		# the error show be programming error, or permission issues. This should be a rare scenario
	say $new_fh ""; # force the system to render as utf8 by inserting some utf8 stuff :)
	# print won't work, it will still be ANSI
	close $new_fh;
	
	say "Yea~ A green leaf '$filename' has grown!";
}

sub grow_leaves {
	say "Your leaf name must include an extension if possible. ",
		"If not, you can still add the extension for the leaf name at some other time.\n";
	say "Seperate your leaves names with a comma(,). We'll try to ignore meaningless ", 
		"\nspace if possible.";
	print "\n", "Name of leaves: ";
	chomp (my $filename = <STDIN>);
	
	my @leaves = split /,\s?/, $filename;
	
	for my $leaf (@leaves) {
		# { # no need, this loop is the same as a naked block
		local $@;
		open my $new_fh, ">:utf8", $leaf
			or die "\nOops~ The leaf '$leaf' withered unexpectedly :|\n", " Reason: $!\n\n";
		
		if ($@) {	say $@;	next;	}
		
		say $new_fh "";	close $new_fh;

		say "Yea~ A green leaf '$leaf' has grown!";
		# }
	}
}

sub nip_leaf {
	print "Which leaf to nip? ";
	chomp (my $leaf = <STDIN>);
	
	print "The leaf '$leaf' will be nipped and burned. Are you sure? (y/n) ";
	chomp (my $response = <STDIN>);
	if ($response eq "y") {
		say "Ok. We're nipping that leaf and then burn it to ashes.";
		unlink $leaf or die "Oops~ We have problems nipping this leaf.\nReason: $!\n";
	}
}

sub _nip_a_leaf_with_warning {
	$_ = shift; 
	# if (-f) {
		unlink or warn "Oops~ Can't nip off '$_' (Reason: $!)\n";
	# }
	# the checking will cause the warn to be useless
}

sub nip_leaf_some {
	say "Which leaves do you want to nip? ";
	print "Leaves names: ";
	chomp (my $leaves = <STDIN>);
	
	my @leaves = split /,\s?/, $leaves;
	
	say "The following leaves will be nipped and burned to ashes:";
	printf "  -> %s\n", $_ for @leaves; 
	
	print "Are you sure? (y/n) ";
	chomp (my $response = lc <STDIN>);
	if ($response eq "y") {
		say "Ok. We're nipping that leaf and then burn it into ashes.";
		
		for (@leaves) {
			&_nip_a_leaf_with_warning($_);
		}
		
		say "All the leaves you specified were nipped and burned, ouch~";
	} elsif ($response eq "n") {
		say "We didn't nip any leaf or burn any of them, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say " Reason: Strange response detected";
	}
}

# I did this one in the actual program :)
# sub nip_leaf_most {
	# print "Which leaf to nip? ";
	# chomp (my $leaf = <STDIN>);
	
	# print "The leaf '$leaf' will be nipped and burned. Are you sure? (y/n) ";
	# chomp (my $response = lc <STDIN>);
	# if ($response eq "y") {
		# say "Ok. We're nipping that leaf and then burn it into ashes.";
		# unlink $leaf 
			# or die "Oops~ We have problems nipping this leaf.\n Reason: $!\n";
		# say "The leaf '$leaf' has been nipped and burned to ashes. Ouch~";
	# } elsif ($response eq "n") {
		# say "We didn't nip the leaf or burn it, don't worry.";
	# } else {
		# say "Cancelling the nipping and burning process . . .";
		# say " Reason: Strange response detected";
	# }
# }

sub nip_leaf_all {
	my $branch = basename(getcwd());
	say "Wow~ Take it easy. This action will nip all the leaves and burn them ALL \ninto ashes.";
	say "You will be nipping ALL the leaves from the branch '$branch'";
	print "Are you sure? (y/n) "; 
	chomp (my $response = lc <STDIN>);
	print "\n";
	
	# actual action
	if ($response eq "y") {
		say "Oh, well. Nipping all the leaves from '$branch' branch and prepare to burn \nthem all. . . ";
		# sleep 3;
		
		# actual action
		for (<./files_to_delete/*>) {
			# next if /(\.|\.\.)/; # this isn't directory handle reading, the . and .. won't be present
			# local $@;
			if (-f) {
				unlink or warn "Oops~ Can't nip off '$_' (Reason: $!)\n";
			}
			# print $@ if $@; # using warn, not die
			# print $success if $verbose; # implemented in the future
		}
		
		say "All the leaves of '$branch' branch were nipped and burned, ouch~";
	} elsif ($response eq "n") {
		say "We didn't nip any of your leaf or burn any of them, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say "Reason: Strange response detected";
	}
}

sub visit {
	print "Visit where? ";
	chomp (my $path = lc <STDIN>);
	
	chdir $path or
		die "Hmm... We couldn't find the road to '$path'\nReason: $!\n";
	use Cwd;
	say getcwd();
	no Cwd;
}

sub leave {
	my $current_dir = basename (getcwd());
	chdir "./.." or
		die "Hmm... We can't seem to leave '$current_dir'\nReason: $!\n";
	say "You left $current_dir";
}

sub banner {
	say "";
	say "~ ~ ~ ~ " x8, "~ ~ ~ ~ ~ ~ ~ ~";
	say "GardenOS version 1.0 (c) 2021 Raphael Jong Jun Jie";
	say " This program is way beyond completion, but there are enough powerful and";
	say "  dangerous tools to make this program useful.";
	say " The complete program will have a garden and an oyster bed with cool features.";
	say " That's all, have fun~";
	say "~ ~ ~ ~ " x8, "~ ~ ~ ~ ~ ~ ~ ~";
}

# besiyata d'shmaya







