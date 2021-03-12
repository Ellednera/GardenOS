#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

# use File::Basename qw(basename);
# use File::Spec qw(catfile);
use Cwd;
use File::HomeDir qw(my_home my_desktop);
use List::MoreUtils qw(one);
use File::Path qw(remove_tree);
use File::Basename "basename";

# PART 1: REGISTER THE COMMANDS

# only register standard commands, omit all flagged commands, leave them to the flag parser
my @commands = ("trunk", "treehouse", "cls", "exit", "explore", "explore leaf", "explore branch", 
				"address", "break branch", "grow branch", "grow leaf", "grow leaves", "nip leaf", 
				"visit", "leave");

my $debug = 1;
# my $do_sth = 0;
my $flagged_command = 0;
our $list_format = "%3s. %-1s\n";

# PART 2: "ACTIVATE" THE COMMANDS (VALIDATION REQUIRED)
# NOTES	: We have a LOOP!
# all the commands are case sensitive
&banner() if not $debug;
while (1) {
	say "Debugging" if $debug;
	print getcwd(), " : ";
	chomp (my $command = lc <STDIN>);
	
	# PART 2-1: COMMAND VALIDATION
	
	if ( ! $command ) {
		redo;
	} elsif ( one {$_ eq $command} @commands) {
		# normal command correct, proceed
		$flagged_command = 0;
		# say "Executing '$command' . . ."; # sleep 2;
	} elsif (rindex ($command, "-") > 0 and &flag_parser($command)) {
		# flags, rindex is faster. Plus, the index of flags will never be 0
		$flagged_command = 1;
		# say "Found a flagged command";
	} else {
		# if not in the list of standard commands, and also not a valid flagged command
		# (either the syntax or the flag has some typo or someting), this part will execute
		say "Can't understand '$command'\n";
			say "Maybe you forgot to register the command?\n"
				if $debug;
		redo;
	}
	
	# PART 2-2: ACTION!
	# do some stuff
	# this part can only run if the validation passes because there's a redo statement involved
	print "\n"; # in-line with the same after this if statement
	if ($flagged_command == 0) {
		
		if ($command eq "trunk") {
			chdir my_home();
			redo; # to avoid the extra \n
		};
		if ($command eq "treehouse") {
			chdir my_desktop();
			say "We're back to the treehouse (desktop), yeah~\n";
			redo;
		}
	
		# explore == dir
		# we need to rebuild this thing some other time
		# the if checking can be simplified for the eval_commands parts
		&explore() if $command eq "explore";
		&explore_leaf() if $command eq "explore leaf";
		&explore_branch() if $command eq "explore branch";
		
		&eval_commands($command) if $command eq "grow branch";
		&eval_commands($command) if $command eq "break branch";
		&eval_commands($command) if $command eq "grow leaf";
		&grow_leaves()			 if $command eq "grow leaves";
		&eval_commands($command) if $command eq "nip leaf";
		&eval_commands($command) if $command eq "visit";
		&eval_commands($command) if $command eq "leave";
		
		# clear screen, modify this command
		system("cls") if $command eq "cls";
		
		# address == current working directory
		if ($command eq "address") {
			say "Your current address is:";
			say "[", getcwd(), "]";
		}
	
		# close the program
		last if $command eq "exit";	
		
	} elsif ($flagged_command) {
	
			&eval_commands($command) if $command eq "break branch -force";
			
			&nip_leaf_all() if $command eq "nip leaf -all";
			&nip_leaf_some() if $command eq "nip leaf -some";
			&nip_leaf_most() if $command eq "nip leaf -most";
	}
	print "\n";
	
}

say "Bye bye~";
# sleep 3; # final release needs this, this is the double click

# PART 4: SUBROUTINES
sub grow_branch {
	# say "Command detected: $command";
	print "Name of your new branch? ";
	chomp (my $branch = <STDIN>);
	die "You are not allowed to grow this branch!".
		"\nReason: Branch name can't start with '.'\n"
		if $branch =~ /\A\.+/;
		# don't allow . and .. to be deleted, dangerous
		# system won't allow too as long as it starts with .
	# sleep 3;
	print "You are about to grow '$branch' branch, are you sure? (y/n) ";
	chomp (my $confirm = lc <STDIN>);
	
	# actual action
	if ($confirm eq "y") {
		say "Growing branch . . .";
		mkdir "./$branch", 0755
			or die "Oops~ The branch '$branch' broke during the growing process.\nReason: $!\n";
		say "'$branch' branch has grown, yeah~";
	} elsif ($confirm eq "n") {
		say "We didn't grow the '$branch' branch, you can grow it at a later time if you want to.";
	} else {
		say "Cancelling growing process . . .";
		say " Reason: Strange response detected.";
	}
	
}

sub break_branch {
	print "Which branch to break? ";
	chomp (my $branch = <STDIN>);
	die "You are not allowed to break this branch!".
		"\nReason: Breaking this branch might \Udestroy\E your computer\n"
		if $branch =~ /\A\.+/; # don't allow . and .. to be deleted, dangerous
	# need to limit the naming style at the grow banch part

	print "'$branch' branch will be broken and burned to ashes, are you sure? (y/n) ";
	chomp (my $confirm = lc <STDIN>);
	
	# actual action
	if ($confirm eq "y") {
		say "Oh, well. Breaking '$branch' and burning it . . .";
		# sleep 3;
		rmdir "./$branch"
			or die "Oops~ The branch '$branch' couldn't be broken.\nReason: $!\n";
		# the system error message is still can be understood easily
		# but not for the grow_branch part
		say "'$branch' branch was broken and burned, ouch~";
	} elsif ($confirm eq "n") {
		say "We didn't break the '$branch' branch, don't worry.";
	} else {
		say "Cancelling breaking and burning process . . .";
		say " Reason: Strange response detected";
	}
	
}

sub break_branch_by_force {
	say "Wow~ Take it easy. This action will strip all the leaves on your branch.";
	say "Both your leaves and the branch will be stripped, broken and burned to ashes.";
	print "Are you sure? (y/n) "; 
	chomp (my $response = lc <STDIN>);
	print "\n";
	
	# actual action
	if ($response eq "y") {
		print "Which branch to break? ";
		chomp (my $branch = <STDIN>);
		die "You are not allowed to break this branch!".
			"\nReason: Breaking this branch might \Udestroy\E your computer\n"
			if $branch =~ /\A\.+/; # don't allow . and .. to be deleted, dangerous
		# need to limit the naming style at the grow banch part

		say "'$branch' branch will be broken, its leaves will be stripped off and everything will";
		print "be burned to ashes, are you sure? (y/n) ";
		chomp (my $confirm = lc <STDIN>);
		
		if ($confirm eq "y") {
			say "Oh, well. Breaking '$branch', stripping leaves and burning them . . .";
			# sleep 3;
			
			remove_tree("./$branch")
				or die "Ermm... We had some difficulties dealing with the '$branch' branch.\n Reason: $!\n";
			
			say "'$branch' branch was broken, its leaves were stripped.";
			say "Everything was burned, ouch~";
		} elsif ($confirm eq "n") {
			say "We didn't break the '$branch' branch, don't worry.";
		} else {
			say "Cancelling the breaking and burning process . . .";
			say " Reason: Strange response detected";
		}
	} elsif ($response eq "n") {
		say "We didn't break any branch, stripped any leaf or burn anything, don't worry.";
	} else {
		say "Cancelling the breaking, stripping and burning process . . .";
		say " Reason: Strange response detected";
	}

}

sub explore {
	say "Here are your leaves on branches~";
	my $item_count = 0;
	for (<*>) {
		if (-d) {
			printf "%3s. %-1s <----[ branch ]\n", ++$item_count, $_;
		} else {
			printf $list_format, ++$item_count, $_;
		}
	}
	
	say "\n", "Found $item_count item(s).";
}

sub explore_leaf {
	say "Here's your leaf/leaves listing~";
	my $leaf_count = 0;
	for (<*>) {
		if (-f) {
			printf $list_format, ++$leaf_count, $_;
		}
	}
	say "\n", "Found $leaf_count leaves.";
}

sub explore_branch {
	say "Here's your branch(es) listing~";
	my $branch_count = 0;	
	for (<*>) {
		if (-d) {
			printf $list_format, ++$branch_count, $_;
		}
	}
	say "\n", "Found $branch_count branch(es).";
}

sub grow_leaf {
	say "Your leaf name must include an extension if possible. ",
		"If not, you can still add the extension for the leaf name at some other time.";
	print "Name of leaf: ";
	chomp (my $filename = <STDIN>);
	
	open my $new_fh, ">:utf8", $filename
		or die "Oops~ Something went wrong with the leaf '$filename'.\nReason: $!";
		# the error show be programming error, or permission issues. This should be a rare scenario
	say $new_fh ""; # force the system to render as utf8 by inserting some utf8 stuff :)
	# print won't work
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

	my @leaves = split /,\s+/, $filename;
	
	for my $leaf (@leaves) {
		local $@;
		open my $new_fh, ">:utf8", $leaf
			or die "\nOops~ The leaf '$leaf' withered unexpectedly :|\n", " Reason: $!\n\n";

		if ($@) { say $@; next; }
		
		say $new_fh "";	close $new_fh;

		say "Yea~ A green leaf '$leaf' has grown!";
	}
}

sub _nip_a_leaf_with_warning {
	$_ = shift; 
	unlink or warn "Oops~ Can't nip off '$_' (Reason: $!)\n";
}

sub nip_leaf {
	print "Which leaf to nip? ";
	chomp (my $leaf = <STDIN>);
	
	print "The leaf '$leaf' will be nipped and burned. Are you sure? (y/n) ";
	chomp (my $response = lc <STDIN>);
	if ($response eq "y") {
		say "Ok. We're nipping that leaf and then burn it into ashes.";
		unlink $leaf 
			or die "Oops~ We have problems nipping this leaf.\n Reason: $!\n";
		say "The leaf '$leaf' has been nipped and burned to ashes. Ouch~";
	} elsif ($response eq "n") {
		say "We didn't nip the leaf or burn it, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say " Reason: Strange response detected";
	}
}

sub nip_leaf_most {
	say "You can keep some of the leaves but the rest in the will be nipped and burned.";
	say "Which leaves do you want to keep in this branch (", basename(getcwd()) , ") ? ";
	print "Leaves names TO KEEP: ";
	chomp (my $leaves = <STDIN>);
	
	my %leaves_to_keep = map { $_ => 1 } split /,\s+/, $leaves;
	
	say "The following leaves will be kept intact:";
	printf " -> %s\n", $_ for keys %leaves_to_keep; 
	
	print "Shoud we proceed? (y/n) ";
	chomp (my $response = lc <STDIN>);
	if ($response eq "y") {
		say "Ok. We're nipping those leave and will burn them into ashes. . .";
		
		# search through the whole FILE list
		for (<*>) {
			if ((-f) && !$leaves_to_keep{$_}) {
				# say "Will delete $_";
				&_nip_a_leaf_with_warning($_);
			}
		}
		say "We kept the leaves you specified but the rest were burned to ashes, ouch~";
	} elsif ($response eq "n") {
		say "We didn't nip any leaf or burn any of them, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say " Reason: Strange response detected";
	}
}

sub nip_leaf_some {
	say "Which leaves do you want to nip? ";
	print "Leaves names: ";
	chomp (my $leaves = <STDIN>);
	
	my @leaves = split /,\s+/, $leaves;
	
	say "The following leaves will be nipped and burned to ashes:";
	printf " -> %s\n", $_ for @leaves; 
	
	print "Are you sure? (y/n) ";
	chomp (my $response = lc <STDIN>);
	if ($response eq "y") {
		say "Ok. We're nipping those leave and will burn them into ashes. . .";
		
		for (@leaves) {
			&_nip_a_leaf_with_warning($_);
		}
		
		say "We've done our best to nip and burn all the leaves you specified, ouch?";
	} elsif ($response eq "n") {
		say "We didn't nip any leaf or burn any of them, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say " Reason: Strange response detected";
	}
}

sub nip_leaf_all {
	my $branch = basename(getcwd());
	say "Wow~ Take it easy. This will nip all the leaves and burn them ALL into ashes.\n";
	say "You will be nipping ALL the leaves from the branch '$branch'";
	print "Are you sure? (y/n) "; 
	chomp (my $response = lc <STDIN>);
	print "\n";
	
	if ($response eq "y") {
		say "Oh, well. Nipping all the leaves from '$branch' branch and preparing to \nburn them all. . . ";
		# sleep 3;
		
		# actual action
		for (<*>) {
			&_nip_a_leaf_with_warning($_);
		}
		
		say "All the leaves of '$branch' branch were nipped and burned, ouch~";
	} elsif ($response eq "n") {
		say "We didn't nip any of your leaf or burn any of them, don't worry.";
	} else {
		say "Cancelling the nipping and burning process . . .";
		say " Reason: Strange response detected";
	}
}

sub visit {
	print "Visit where? ";
	# chomp (my $path = lc <STDIN>);
	chomp (my $path = <STDIN>);
	chdir $path or
		die "Hmm... We couldn't find the road to '$path'\n Reason: $!\n";
	say "We've arrived safely at the destination '$path', yeah~";
}

sub leave {
	my $current_dir = basename (getcwd());
	chdir "./.." or
		die "Hmm... We can't seem to leave '$current_dir'\n Reason: $!\n";
	say "You left '$current_dir'.";
}

# PART 5: REFACTORED CODES (DON'T DO THIS OFTEN)
sub eval_commands {
	# all functions that need the eval block to work are in this subroutine
	# there are some execptions of course :)
	my $command = shift or 
		warn "Programming error! Parameter missing (validated_command)\n", 
			"If you are the user, please contact the developers, thanks.";
	{
		local $@;
		
		# these if-elsif statements will only execute once and only one action will be executed
		if ($command eq "break branch") {
			eval {	&break_branch()	};
		} elsif ($command eq "break branch -force") {
			eval {	&break_branch_by_force()	};
		} elsif ($command eq "grow branch") {
			eval {	&grow_branch()	};
		} elsif ($command eq "grow leaf") {
			eval {	&grow_leaf()	};
		} elsif ($command eq "nip leaf") {
			eval {	&nip_leaf()	};
		} elsif ($command eq "visit") {
			eval {	&visit()	};
		} elsif ($command eq "leave") {
			eval {	&leave()	};
		}
		
		print $@ if $@;
	}
}

# PART 6: THE PARSER, FINALLY!
sub flag_parser {
	my $command = shift;
	my @parts = split /\s+/, $command;

	if ($parts[0] eq "break") {
		if ($parts[1] eq "branch") {
			if ($parts[2] eq "-force") { 1 }
			else { 0 }
		} else { 0 }
	} elsif ($parts[0] eq "nip") {
		if ($parts[1] eq "leaf") {
			if ($parts[2] eq "-all") { 1 } 
			elsif ($parts[2] eq "-some") { 1 } 
			elsif ($parts[2] eq "-most") { 1 } 
			else { 0 }
		} else { 0 }
	} else { 0 }
}

# PART 7: DETAILS
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


