#!/usr/bin/env bash
bin=~/riak-2.2.3/bin
RIAK_HOST=http://localhost:8098

curl -XPUT $RIAK_HOST/search/index/users \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'

curl -XPUT $RIAK_HOST/search/index/test-users \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'

curl -XPUT $RIAK_HOST/search/index/notification-users \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'

curl -XPUT $RIAK_HOST/search/index/test-notification-users \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'

curl -XPUT $RIAK_HOST/search/index/notifications \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'

curl -XPUT $RIAK_HOST/search/index/test-notifications \
     -H 'Content-Type: application/json' \
     -d '{"schema":"_yz_default"}'
#create bucket types.
$bin/riak-admin bucket-type create users '{"props":{"datatype":"map","search_index":"users"}}'
$bin/riak-admin bucket-type activate users

$bin/riak-admin bucket-type create notification-users '{"props":{"datatype":"map", "search_index":"notification-users"}}'
$bin/riak-admin bucket-type activate notification-users

$bin/riak-admin bucket-type create notifications '{"props":{"datatype":"map", "search_index":"notifications"}}'
$bin/riak-admin bucket-type activate notifications


#ceate test buckets types.
$bin/riak-admin bucket-type create test-users '{"props":{"datatype":"map","search_index":"test-users"}}'
$bin/riak-admin bucket-type activate test-users

$bin/riak-admin bucket-type create test-notification-users '{"props":{"datatype":"map", "search_index":"test-notification-users"}}'
$bin/riak-admin bucket-type activate test-notification-users

$bin/riak-admin bucket-type create test-notifications '{"props":{"datatype":"map","search_index":"test-notifications"}}'
$bin/riak-admin bucket-type activate test-notifications

$bin/riak-admin bucket-type create maps '{"props":{"datatype":"map"}}'
$bin/riak-admin bucket-type activate maps
