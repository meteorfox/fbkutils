#!/usr/bin/env python3
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import unittest

from benchpress.plugins.parsers.nginx_wrk_bench import NginxWrkParser


class TestNginxWrkParser(unittest.TestCase):
    def setUp(self):
        self.parser = NginxWrkParser()

    def test_sample_output(self):
        output = [
            'Running 10s test @ http://127.0.0.1:8080/index.html',
            '2 threads and 100 connections',
            'Thread Stats   Avg      Stdev     Max   +/- Stdev',
            'Latency   105.31ms  212.37ms   1.98s    93.98%',
            'Req/Sec   796.06    266.58     1.62k    81.63%',
            'Latency Distribution',
            '50%   62.12ms',
            '75%   63.36ms',
            '90%   74.62ms',
            '99%    1.27s',
            '15545 requests in 10.01s, 12.60MB read',
            'Socket errors: connect 0, read 0, write 0, timeout 25',
            'Requests/sec:   1552.47',
            'Transfer/sec:      1.26MB',
        ]
        metrics = self.parser.parse(output, None, 0)
        self.assertDictEqual({'Requests/sec': float(1552.47)}, metrics)


if __name__ == '__main__':
    unittest.main()
