use v6;
unit class Algorithm::BloomFilter;

has Rat $.error-rate;
has Int $.capacity;
has Int $.key-count;
has Int $.filter-length;
has Int $.num-hash-funcs;
has Num @.salts;
has Buf $.filter;
has Buf $.blankvec;

method BUILD(Rat:D :$!error-rate, Int:D :$!capacity) {
    my %filter-settings = self.calculate-shortest-filter-length(
        num-keys   => $!capacity,
        error-rate => $!error-rate,
    );
    $!key-count      = 0;
    $!filter-length  = %filter-settings<length>;
    $!num-hash-funcs = %filter-settings<num-hash-funcs>;
    @!salts          = self.create-salts($!num-hash-funcs);

    #XXX TODO: Make an empty filter
    #XXX TODO: Make blank vectors
}

method calculate-shortest-filter-length(Int:D :$num-keys, Rat:D :$error-rate --> Hash[Int]) {
    my Num $lowest-m;
    my Int $best-k = 1;

    for 1 .. 100 -> $k {
        my $m = (-1 * $k * $num-keys) / (log(1 - ($error-rate ** (1/$k))));

        if (!$lowest-m.defined || ($m < $lowest-m)) {
            $lowest-m = $m;
            $best-k   = $k;
        }
    }

    my Int %result =
        length         => $lowest-m.Int + 1,
        num-hash-funcs => $best-k;
}

method create-salts(Int:D $count --> Array[Num]) {
    my Num %collisions;

    while %collisions.keys.elems < $count {
        my Num $c = rand;
        %collisions{$c} = $c;
    }

    my Num @array = %collisions.values;
}

=begin pod

=head1 NAME

Algorithm::BloomFilter - blah blah blah

=head1 SYNOPSIS

  use Algorithm::BloomFilter;

=head1 DESCRIPTION

Algorithm::BloomFilter is ...

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
