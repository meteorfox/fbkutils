#!/usr/bin/env python3
# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import unittest

from benchpress.plugins.parsers.django_workload import DjangoWorkloadParser


class TestDjangoWorkloadParser(unittest.TestCase):

    def setUp(self):
        self.parser = DjangoWorkloadParser()

    def compare_metric_dicts(self, expected_dict, actual_dict):
        expected_keys = sorted(expected_dict.keys())
        actual_keys = sorted(actual_dict.keys())
        if expected_keys == actual_keys:
            assert(False, 'Keys of two dictionaries are not the same')
            return

        for key in expected_keys:
            expected_val = expected_dict[key]
            actual_val = actual_dict[key]
            assert(
                expected_val == actual_val,
                'Values are not equal: {} != {}'.format(expected_val, actual_val)
            )

    def test_empty_output(self):
        dw_output = []
        expected_output = {}
        metrics = self.parser.parse(dw_output, [], 1)
        self.compare_metric_dicts(expected_output, metrics)

    def test_parse_failed_output(self):
        dw_output = [
            "Running iteration 1 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_1",
            "\n",
            "Running iteration 2 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_2",
            "\n",
            "Running iteration 3 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_3",
            "\n",
            "Running iteration 4 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_4",
            "\n",
            "Running iteration 5 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_5",
            "\n",
            "Running iteration 6 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_6",
            "\n",
            "Running iteration 7 --- DONE",
            "WARNING: Got 1167 connection refused errors",
            "Please see full Siege log in /tmp/siege_out_7",
            "\n",
            "\n",
            "Removing results with Transaction rate min=0.0 and max=0.0",
            "\n",
            "URL hit percentages:",
            "/seen:          0.0%, expected 5%",
            "/timeline:      0.0%, expected 25%",
            "/inbox:         0.0%, expected 19%",
            "/bundle_tray:       0.0%, expected 25%",
            "/feed_timeline:     0.0%, expected 26%",
            "\n",
            "Transactions:               0.0 hits ---- RSD 0",
            "Availability:               0.0 % ---- RSD 0",
            "Elapsed time:               0.082 secs ---- RSD 0.0912599362628",
            "Data transferred:           0.0 MB ---- RSD 0",
            "Response time:              0.0 secs ---- RSD 0",
            "Transaction rate:           0.0 trans/sec ---- RSD 0",
            "Throughput:             0.0 MB/sec ---- RSD 0",
            "Concurrency:                0.0  ---- RSD 0",
            "Successful transactions:        0.0  ---- RSD 0",
            "Failed transactions:            1167.0  ---- RSD 0.0",
            "Longest transaction:            0.0  ---- RSD 0",
            "Shortest transaction:           0.0  ---- RSD 0",
            "P50:                    N/A, please check Siege output file(s)",
            "P90:                    N/A, please check Siege output file(s)",
            "P95:                    N/A, please check Siege output file(s)",
            "P99:                    N/A, please check Siege output file(s)",
            "\n",
            "Full Siege output is available in /tmp/siege_out_[N]"
        ]
        expected_output = {
            "URL hit percentages" : {
                "/seen" : 0.0,
                "/timeline" : 0.0,
                "/inbox" : 0.0,
                "/bundle_tray" : 0.0,
                "/feed_timeline" : 0.0
            },
            "Transactions_hits" : 0.0,
            "Availability_%" : 0.0,
            "Elapsed time_secs" : 0.0,
            "Data transferred_MB" : 0.0,
            "Response time_secs" : 0.0,
            "Transaction rate_trans/sec" : 0.0,
            "Throughput_MB/sec" : 0.0,
            "Concurrency" : 0.0,
            "Successful transactions" : 0.0,
            "Failed transactions" : 1167.0,
            "Longest transaction" : 0.0,
            "Shortest transaction" : 0.0,
            "P50" : -1.0,
            "P90" : -1.0,
            "P95" : -1.0,
            "P99" : -1.0
        }
        metrics = self.parser.parse(dw_output, [], 1)
        self.compare_metric_dicts(expected_output, metrics)

    def test_parse_expected_output(self):
        dw_output = [
            "Running iteration 1 --- DONE",
            "WARNING: Got 12 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_1",
            "\n",
            "Running iteration 2 --- DONE",
            "WARNING: Got 15 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_2",
            "\n",
            "Running iteration 3 --- DONE",
            "WARNING: Got 39 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_3",
            "\n",
            "Running iteration 4 --- DONE",
            "WARNING: Got 63 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_4",
            "\n",
            "Running iteration 5 --- DONE",
            "WARNING: Got 34 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_5",
            "\n",
            "Running iteration 6 --- DONE",
            "WARNING: Got 44 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_6",
            "\n",
            "Running iteration 7 --- DONE",
            "WARNING: Got 65 HTTP codes different than 200",
            "Please see full Siege log in /tmp/siege_out_7",
            "\n",
            "\n",
            "Removing results with Transaction rate min=126.1 and max=321.0",
            "\n",
            "URL hit percentages:",
            "/seen:			6.70509841888%, expected 5%",
            "/inbox:			18.1104053374%, expected 19%",
            "/timeline:		25.7365801768%, expected 25%",
            "/feed_timeline:		23.0797435138%, expected 26%",
            "/bundle_tray:		26.3664189787%, expected 25%",
            "\n",
            "Transactions:				26059.8 hits ---- RSD 0.223504355592",
            "Availability:				99.83 % ---- RSD 0.00099365695824",
            "Elapsed time:				119.804 secs ---- RSD 0.000539913913686",
            "Data transferred:			51.362 MB ---- RSD 0.22504760529",
            "Response time:				0.646 secs ---- RSD 0.203864738491",
            "Transaction rate:			217.518 trans/sec ---- RSD 0.223460506355",
            "Throughput:				0.428 MB/sec ---- RSD 0.22037058173",
            "Concurrency:				133.842  ---- RSD 0.0677907822776",
            "Successful transactions:		26059.8  ---- RSD 0.223504355592",
            "Failed transactions:			39.4  ---- RSD 0.393720191465",
            "Longest transaction:			27.458  ---- RSD 0.311683103993",
            "Shortest transaction:			0.082  ---- RSD 0.0487804878049",
            "P50:					0.304 secs ---- RSD 0.0573539334676",
            "P90:					0.832 secs ---- RSD 0.404418093169",
            "P95:					1.478 secs ---- RSD 0.283535607117",
            "P99:					7.074 secs ---- RSD 0.428916627845",
            "\n",
            "Full Siege output is available in /tmp/siege_out_[N]"
        ]
        expected_output = {
            "URL hit percentages" : {
                "/seen" : 6.705,
                "/timeline" : 25.737,
                "/inbox" : 18.110,
                "/bundle_tray" : 26.366,
                "/feed_timeline" : 23.080
            },
            "Transactions_hits" : 26059.80,
            "Availability_%" : 99.830,
            "Elapsed time_secs" : 119.804,
            "Data transferred_MB" : 51.362,
            "Response time_secs" : 0.646,
            "Transaction rate_trans/sec" : 217.518,
            "Throughput_MB/sec" : 0.428,
            "Concurrency" : 133.842,
            "Successful transactions" : 26059.800,
            "Failed transactions" : 39.400,
            "Longest transaction" : 27.458,
            "Shortest transaction" : 0.082,
            "P50_secs" : 0.304,
            "P90_secs" : 0.832,
            "P95_secs" : 1.478,
            "P99_secs" : 7.074
        }
        metrics = self.parser.parse(dw_output, [], 0)
        self.compare_metric_dicts(expected_output, metrics)

if __name__ == '__main__':
    unittest.main()
