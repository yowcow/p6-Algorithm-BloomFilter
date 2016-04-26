use v6;
use experimental :pack;
use Digest::SHA;

unit class Algorithm::BloomFilter;

has Rat $.error-rate;
has Int $.capacity;
has Int $.key-count;
has Int $.filter-length;
has Int $.num-hash-funcs;
has Num @.salts;
has Buf $.filter;
has Int $.blankvec;

method BUILD(Rat:D :$!error-rate, Int:D :$!capacity) {
    my %filter-settings = self.calculate-shortest-filter-length(
        num-keys   => $!capacity,
        error-rate => $!error-rate,
    );
    $!key-count      = 0;
    $!filter-length  = %filter-settings<length>;
    $!num-hash-funcs = %filter-settings<num-hash-funcs>;
    @!salts          = self.create-salts(count => $!num-hash-funcs);

    # Create an empty filter
    $!filter = Buf.new((for 1 .. $!filter-length { 0 }));

    # Create a blank vector
    $!blankvec = 0;
}

method calculate-shortest-filter-length(Int:D :$num-keys, Rat:D :$error-rate --> Hash[Int]) {
    my Num $lowest-m;
    my Int $best-k = 1;

    for 1 ... 100 -> $k {
        my $m = (-1 * $k * $num-keys) / (log(1 - ($error-rate ** (1 / $k))));

        if (!$lowest-m.defined || ($m < $lowest-m)) {
            $lowest-m = $m;
            $best-k   = $k;
        }
    }

    my Int %result =
        length         => $lowest-m.Int + 1,
        num-hash-funcs => $best-k;
}

method create-salts(Int:D :$count --> Array[Num]) {
    my Num %collisions;

    while %collisions.keys.elems < $count {
        my Num $c = rand;
        %collisions{$c} = $c;
    }

    my Num @array = %collisions.values;
}

method get-cells(Any:D $key, Int:D :$filter-length, Int:D :$blankvec, Num:D :@salts --> Array[Int]) {
    my Int @cells;

    for @salts -> $salt {
        my Int $vec = $blankvec;
        my Int @pieces = sha1($key ~ $salt).unpack('N*');

        $vec = $vec +^ $_ for @pieces;

        @cells.push: $vec % $filter-length; # push bit-offset
    }

    @cells;
}

method add(Mu:D: Any:D $key) {

    die "Exceeded filter capacity: {$!capacity}"
        if $!key-count >= $!capacity;

    $!key-count++;

    $!filter[$_] = 1 for self.get-cells(
        $key,
        filter-length => $!filter-length,
        blankvec      => $!blankvec,
        salts         => @!salts,
    );
}

method check(Mu:D: Any:D $key --> Bool) {
    so $!filter[
        self.get-cells(
            $key,
            filter-length => $!filter-length,
            blankvec      => $!blankvec,
            salts         => @!salts,
        )
    ].all === 1;
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
