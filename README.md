[![Build Status](https://travis-ci.org/yowcow/p6-Algorithm-BloomFilter.svg?branch=master)](https://travis-ci.org/yowcow/p6-Algorithm-BloomFilter)

NAME
====

Algorithm::BloomFilter - A bloom filter implementation in Perl 6

SYNOPSIS
========

    use Algorithm::BloomFilter;

    my $filter = Algorithm::BloomFilter.new(
      capacity   => 100,
      error-rate => 0.01,
    );

    $filter.add("foo-bar");

    $filter.check("foo-bar"); # True

    $filter.check("bar-foo"); # False with false-positive possibility

DESCRIPTION
===========

Algorithm::BloomFilter is a pure Perl 6 implementation of [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter), mostly based on [Bloom::Filter](https://metacpan.org/pod/Bloom::Filter) from Perl 5.

AUTHOR
======

yowcow <yowcow@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
