use v6;
use Algorithm::BloomFilter;
use Test;

subtest {

    my Int %filter := Algorithm::BloomFilter.calculate-shortest-filter-length(
        num-keys   => 1092,
        error-rate => 0.00001
    );

    is %filter<length>, 26172;
    is %filter<num-hash-funcs>, 17;

}, 'Test calculate-shortest-filter-length';

subtest {

    subtest {

        my Num @salts = Algorithm::BloomFilter.create-salts(1);

        is @salts.elems, 1;

    }, 'When 1';

    subtest {

        my Num @salts = Algorithm::BloomFilter.create-salts(5);

        is @salts.elems, 5;

    }, 'When 5';

}, 'Test create-salts';

subtest {

    subtest {

        dies-ok { Algorithm::BloomFilter.new }, 'Dies without error-rate and capacity';
        dies-ok { Algorithm::BloomFilter.new(error-rate => 0.001) }, 'Dies without error-rate';
        dies-ok { Algorithm::BloomFilter.new(capacity => 10000) }, 'Dies without capacity';

    }, 'Fails with invalid parameters';

    subtest {

        my Algorithm::BloomFilter $bloom .= new(
            error-rate => 0.00001,
            capacity   => 1092,
        );

        isa-ok $bloom, 'Algorithm::BloomFilter';
        is $bloom.error-rate, 0.00001;
        is $bloom.capacity,   1092;
        is $bloom.key-count,  0;
        is $bloom.filter-length,  26172;
        is $bloom.num-hash-funcs, 17;
        is $bloom.salts.elems,    17;

    }, 'Succeeds with valid parameters';

}, 'Test new';

done-testing;
