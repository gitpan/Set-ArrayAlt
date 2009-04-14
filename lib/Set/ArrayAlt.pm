package Set::ArrayAlt;
# Copyright (c) 2009-2009 Sullivan Beck. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

###############################################################################

require 5.004;

use warnings;
use strict;
use Sort::DataTypes qw(sort_by_method sort_valid_method);

use vars qw($VERSION);
$VERSION = "1.00";

###############################################################################
# BASE METHODS
###############################################################################

sub new {
   my($class,@array) = @_;

   my $self = {
               "set"  => undef,
               "err"  => "",
              };
   bless $self, $class;

   $self->list(@array)  if (@array);
   return $self;
}

sub version {
   my($self) = @_;

   return $VERSION;
}

sub err {
   my($self) = @_;

   return 1  if ($$self{"err"});
   return 0;
}

sub errmsg {
   my($self) = @_;

   return $$self{"err"};
}

###############################################################################
# LIST EXAMINATION METHODS
###############################################################################

sub list {
   my($self,@list) = @_;
   $$self{"err"}   = "";

   if (@list) {
      $$self{"set"} = [@list];
      return;
   } elsif (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   } else {
      return @{ $$self{"set"} };
   }
}

sub length {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   return $#{ $$self{"set"} } + 1;
}

sub at {
   my($self,@n) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   } elsif (! @n) {
      $$self{"err"} = "Index required";
      return undef;
   } elsif ($#n > 0  &&  ! wantarray) {
      $$self{"err"} = "In scalar context, only a single index allowed";
      return undef;
   }

   my(@ret);
   my $len = $self->length();

   foreach my $n (@n) {
      if ($n =~ /^[+-]?\d+$/) {
         if ($n < -$len  ||  $n > $len-1) {
            $$self{"err"} = "Index out of range";
            return undef;
         }
         CORE::push(@ret,$$self{"set"}[$n]);
      } else {
         $$self{"err"} = "Index must be an integer";
         return undef;
      }
   }

   if (wantarray) {
      return @ret;
   } else {
      return $ret[0];
   }
}

sub first {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   return $$self{"set"}[0];
}

sub last {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   return $$self{"set"}[$#{ $$self{"set"} }];
}

sub index {
   my($self,$val) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @idx  = ();
   my @list = @{ $$self{"set"} };

   for (my $i=0; $i<=$#list; $i++) {
      my $ele = $list[$i];
      CORE::push(@idx,$i)
          if ((defined $ele  &&  defined $val  &&  $ele eq $val)  ||
              (! defined $val  &&  ! defined $ele));
   }

   if (wantarray) {
      return @idx;
   } else {
      return $idx[0];
   }
}

sub rindex {
   my($self,$val) = @_;
   my @idx = $self->index($val);
   return undef  if ($self->err());

   if (wantarray) {
      return CORE::reverse(@idx);
   } else {
      return $idx[$#idx];
   }
}

sub count {
   my($self,$val) = @_;
   my @idx = $self->index($val);
   return undef  if ($self->err());

   return $#idx + 1;
}

sub exists {
   my($self,$val) = @_;
   my @idx = $self->index($val);
   return undef  if ($self->err());

   return 1  if ($#idx > -1);
   return 0;
}

sub is_empty {
   my($self,$undef) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = @{ $$self{"set"} };
   return 1  if ($#list == -1);

   foreach my $ele (@list) {
      next  if ($undef  &&  ! defined $ele);
      return 0;
   }

   return 1;
}

sub as_hash {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my %tmp;
   foreach my $ele (@{ $$self{"set"} }) {
      next  if (! defined $ele);
      if (exists $tmp{$ele}) {
         $tmp{$ele}++;
      } else {
         $tmp{$ele} = 1;
      }
   }

   return %tmp;
}

###############################################################################
# SIMPLE LIST MODIFICATION METHODS
###############################################################################

sub clear {
   my($self,$undef) = @_;
   $$self{"err"}   = "";

   if ($undef) {
      if (! defined $$self{"set"}) {
         $$self{"err"} = "List undefined";
         return undef;
      }
      foreach my $ele (@{ $$self{"set"} }) {
         $ele = undef;
      }

   } else {
      $$self{"set"} = [];
   }

   return;
}

sub compact {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = ();
   foreach my $ele (@{ $$self{"set"} }) {
      CORE::push(@list,$ele)  if (defined $ele);
   }
   $$self{"set"} = [@list];
   return;
}

sub unique {
   my($self) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = ();
   my %list = ();
   my $undef = 0;

   foreach my $ele (@{ $$self{"set"} }) {
      if (! defined($ele)) {
         if (! $undef) {
            CORE::push(@list,$ele);
            $undef = 1;
         }
      } elsif (! CORE::exists $list{$ele}) {
         CORE::push(@list,$ele);
         $list{$ele} = 1;
      }
   }
   $$self{"set"} = [@list];
   return;
}

sub push {
   my($self,@list) = @_;
   $$self{"err"}   = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   CORE::push(@{ $$self{"set"} },@list);
   return;
}

sub pop {
   my($self) = @_;
   $$self{"err"}   = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my $val = CORE::pop @{ $$self{"set"} };
   return $val;
}

sub unshift {
   my($self,@list) = @_;
   $$self{"err"}   = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   CORE::unshift(@{ $$self{"set"} },@list);
   return;
}

sub shift {
   my($self) = @_;
   $$self{"err"}   = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my $val = CORE::shift @{ $$self{"set"} };
   return $val;
}

sub reverse {
   my($self) = @_;
   $$self{"err"}   = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = @{ $$self{"set"} };
   $$self{"set"} = [ CORE::reverse(@list) ];
   return;
}

sub rotate {
   my($self,$n) = @_;
   $n = 1  if (! defined $n);
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   } elsif ($n !~ /^[+-]?\d+$/) {
      $$self{"err"} = "Rotation number must be an integer";
      return undef;
   }

   my @list = @{ $$self{"set"} };
   if ($n > 0) {
      for (my $i=1; $i<=$n; $i++) {
         CORE::push(@list,CORE::shift(@list));
      }
   } elsif ($n < 0) {
      $n *= -1;
      for (my $i=1; $i<=$n; $i++) {
         CORE::unshift(@list,CORE::pop(@list));
      }
   }

   $$self{"set"} = [@list];
   return;
}

sub sort {
   my($self,$method,@args) = @_;

   if (! defined $method) {
      $method = "alphabetic";
   }

   my(@list) = _sort($self,$method,@args);
   return undef  if ($self->err());

   $$self{"set"} = [@list];
   return;
}

sub _sort {
   my($self,$method,@args) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   if (! sort_valid_method($method)) {
      $$self{"err"} = "Invalid sort method";
      return undef;
   }

   my @list = @{ $$self{"set"} };
   sort_by_method($method,\@list,@args);
   return @list;
}

sub randomize {
   my($self) = @_;
   $self->sort("random");
}

sub min {
   my($self,$method,@args) = @_;

   if (! defined $method) {
      $method = "numerical";
   }

   my(@list) = _sort($self,$method,@args);
   return undef  if ($self->err());

   return $list[0];
}

sub max {
   my($self,$method,@args) = @_;

   if (! defined $method) {
      $method = "numerical";
   }

   my(@list) = _sort($self,$method,@args);
   return undef  if ($self->err());

   return $list[$#list];
}

sub fill {
   my($self,$val,$start,$length) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = @{ $$self{"set"} };

   $start = 0  if (! $start);
   if ($start !~ /^[+-]?\d+$/) {
      $$self{"err"} = "Start must be an integer";
      return undef;
   }
   if ($start < -($#list + 1)  ||
       $start > $#list + 1) {
      $$self{"err"} = "Start out of bounds";
      return undef;
   }
   if ($start < 0) {
      $start = $#list + 1 + $start;
   }

   if (! defined $length) {
      if ($start > $#list) {
         $length = 1;
      } else {
         $length = ($#list + 1 - $start);
      }
   }

   if ($length !~ /^\d+$/) {
      $$self{"err"} = "Length must be an unsigned integer";
      return undef;
   }
   my $end = $start + $length - 1;

   foreach my $i ($start..$end) {
      $list[$i] = $val;
   }

   $$self{"set"} = [@list];
   return;
}

sub splice {
   my($self,$start,$length,@vals) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = @{ $$self{"set"} };

   $start = 0  if (! $start);
   if ($start !~ /^[+-]?\d+$/) {
      $$self{"err"} = "Start must be an integer";
      return undef;
   }
   if ($start < -($#list + 1)  ||
       $start > $#list) {
      $$self{"err"} = "Start out of bounds";
      return undef;
   }
   if ($start < 0) {
      $start = $#list + 1 + $start;
   }

   if (! defined $length) {
      if ($start > $#list) {
         $length = 1;
      } else {
         $length = ($#list + 1 - $start);
      }
   }

   if ($length !~ /^\d+$/) {
      $$self{"err"} = "Length must be an unsigned integer";
      return undef;
   }
   my $end = $start + $length - 1;

   my @ret = CORE::splice(@list,$start,$length,@vals);

   $$self{"set"} = [@list];
   return @ret;
}

sub set {
   my($self,$index,$val) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }
   if (! defined $index) {
      $$self{"err"} = "Index required";
      return undef;
   }

   my @list = @{ $$self{"set"} };

   if ($index !~ /^[+-]?\d+$/) {
      $$self{"err"} = "Index must be an integer";
      return undef;
   }
   if ($index < -($#list + 1)  ||
       $index > $#list) {
      $$self{"err"} = "Index out of bounds";
      return undef;
   }

   $$self{"set"}[$index] = $val;
   return;
}

sub delete {
   my($self,$all,$undef,@val) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   foreach my $val (@val) {
      my(@idx);
      if ($all) {
         @idx = $self->rindex($val);
      } else {
         my $idx = $self->index($val);
         @idx = ($idx);
      }

      if ($undef) {
         foreach my $idx (@idx) {
            $$self{"set"}[$idx] = undef;
         }
      } else {
         foreach my $idx (@idx) {
            CORE::splice(@{ $$self{"set"} },$idx,1);
         }
      }
   }
   return;
}

sub delete_at {
   my($self,$undef,@idx) = @_;
   $$self{"err"} = "";

   if (! defined $$self{"set"}) {
      $$self{"err"} = "List undefined";
      return undef;
   }

   my @list = @{ $$self{"set"} };
   foreach my $idx (@idx) {
      if ($idx !~ /^[+-]?\d+$/) {
         $$self{"err"} = "Index must be an integer";
         return undef;
      }
      if ($idx < -($#list + 1)  ||
          $idx > $#list) {
         $$self{"err"} = "Index out of bounds";
         return undef;
      }
      if ($idx < 0) {
         $idx = $#list + 1 + $idx;
      }
   }
   @idx = sort { $b <=> $a } @idx;

   if ($undef) {
      foreach my $idx (@idx) {
         $$self{"set"}[$idx] = undef;
      }
   } else {
      foreach my $idx (@idx) {
         CORE::splice(@{ $$self{"set"} },$idx,1);
      }
   }
   return;
}

###############################################################################
# SET METHODS
###############################################################################

sub union {
   my($obj1,$obj2,$unique) = @_;

   my $class = ref($obj1);
   my $ret   = new $class;

   if (ref($obj2) ne $class) {
      $$ret{"err"} = "Obj2 not of the right class";
      return $ret;
   }

   if (! defined $$obj1{"set"}) {
      $$ret{"err"} = "List undefined in obj1";
      return $ret;
   }
   if (! defined $$obj2{"set"}) {
      $$ret{"err"} = "List undefined in obj2";
      return $ret;
   }

   my @list1 = @{ $$obj1{"set"} };
   my @list2 = @{ $$obj2{"set"} };

   $ret->list(@list1,@list2);
   if ($unique) {
      $ret->unique();
   }

   return $ret;
}

sub difference {
   my($obj1,$obj2,$unique) = @_;

   my $class = ref($obj1);
   my $ret   = new $class;

   if (ref($obj2) ne $class) {
      $$ret{"err"} = "Obj2 not of the right class";
      return $ret;
   }

   if (! defined $$obj1{"set"}) {
      $$ret{"err"} = "List undefined in obj1";
      return $ret;
   }
   if (! defined $$obj2{"set"}) {
      $$ret{"err"} = "List undefined in obj2";
      return $ret;
   }

   my @list1 = @{ $$obj1{"set"} };
   my %list2 = $obj2->as_hash();
   my $undef = $obj2->count();

   my @list;
   foreach my $ele (@list1) {
      if (! defined $ele  &&  $undef > 0) {
         next  if ($unique);
         $undef--;
         next;

      } elsif (CORE::exists $list2{$ele}  &&  $list2{$ele}) {
         next  if ($unique);
         $list2{$ele}--;
         next;
      }

      CORE::push(@list,$ele);
   }

   $ret->list(@list);
   return $ret;
}

sub intersection {
   my($obj1,$obj2,$unique) = @_;

   my $class = ref($obj1);
   my $ret   = new $class;

   if (ref($obj2) ne $class) {
      $$ret{"err"} = "Obj2 not of the right class";
      return $ret;
   }

   if (! defined $$obj1{"set"}) {
      $$ret{"err"} = "List undefined in obj1";
      return $ret;
   }
   if (! defined $$obj2{"set"}) {
      $$ret{"err"} = "List undefined in obj2";
      return $ret;
   }

   my @list1  = @{ $$obj1{"set"} };
   my %list2  = $obj2->as_hash();
   my $undef  = $obj2->count();

   my @list;
   foreach my $ele (@list1) {
      if ( (! defined $ele  &&  $undef)  ||
           (defined $ele    &&  CORE::exists $list2{$ele}) ) {
         CORE::push(@list,$ele);
      }
   }

   $ret->list(@list);
   $ret->unique()  if ($unique);
   return $ret;
}

sub symmetric_difference {
   my($obj1,$obj2,$unique) = @_;

   my $class = ref($obj1);
   my $ret   = new $class;

   if (ref($obj2) ne $class) {
      $$ret{"err"} = "Obj2 not of the right class";
      return $ret;
   }

   if (! defined $$obj1{"set"}) {
      $$ret{"err"} = "List undefined in obj1";
      return $ret;
   }
   if (! defined $$obj2{"set"}) {
      $$ret{"err"} = "List undefined in obj2";
      return $ret;
   }

   my @list1  = @{ $$obj1{"set"} };
   my @list2  = @{ $$obj2{"set"} };
   my %list1  = $obj1->as_hash();
   my %list2  = $obj2->as_hash();
   my $undef1 = $obj1->count();
   my $undef2 = $obj2->count();

   my @list;
   if ($unique) {
      foreach my $ele (@list1) {
         next  if (! defined $ele  &&  $undef2);
         next  if (defined $ele    &&  CORE::exists $list2{$ele});
         CORE::push(@list,$ele);
      }
      foreach my $ele (@list2) {
         next  if (! defined $ele  &&  $undef1);
         next  if (defined $ele    &&  CORE::exists $list1{$ele});
         CORE::push(@list,$ele);
      }

   } else {
      foreach my $ele (@list1) {
         $undef2--, next       if (! defined $ele  &&
                                   $undef2);
         $list2{$ele}--, next  if (defined $ele  &&
                                   CORE::exists $list2{$ele}  &&
                                   $list2{$ele});
         CORE::push(@list,$ele);
      }
      foreach my $ele (@list2) {
         $undef1--, next       if (! defined $ele  &&
                                   $undef1);
         $list1{$ele}--, next  if (defined $ele  &&
                                   CORE::exists $list1{$ele}  &&
                                   $list1{$ele});
         CORE::push(@list,$ele);
      }
   }

   $ret->list(@list);
   return $ret;
}

sub is_equal {
   my($obj1,$obj2,$unique) = @_;

   my $class = ref($obj1);

   if (ref($obj2) ne $class  ||
       ! defined $$obj1{"set"}  ||
       ! defined $$obj2{"set"}) {
      return undef;
   }

   my %list1  = $obj1->as_hash();
   my %list2  = $obj2->as_hash();
   my $undef1 = $obj1->count();
   my $undef2 = $obj2->count();

   if ($unique) {
      return 0  if (($undef1  &&  ! $undef2) ||
                    (! $undef1  &&  $undef2));
      foreach my $ele (keys %list1) {
         return 0  if (! exists $list2{$ele});
      }
      foreach my $ele (keys %list2) {
         return 0  if (! exists $list1{$ele});
      }

   } else {
      return 0  if ($undef1 != $undef2);
      foreach my $ele (keys %list1) {
         return 0  if (! exists $list2{$ele}  ||
                       $list1{$ele} != $list2{$ele});
      }
      foreach my $ele (keys %list2) {
         return 0  if (! exists $list1{$ele});
      }
   }

   return 1;
}

sub not_equal {
   return 1 - is_equal(@_);
}

1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 3
# cperl-continued-statement-offset: 2
# cperl-continued-brace-offset: 0
# cperl-brace-offset: 0
# cperl-brace-imaginary-offset: 0
# cperl-label-offset: -2
# End:
