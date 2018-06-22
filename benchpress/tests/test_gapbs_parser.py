# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import unittest

from benchpress.plugins.parsers.gapbs import GAPBSParser


class TestGAPBSParser(unittest.TestCase):

    def setUp(self):
        self.parser = GAPBSParser()

    def test_bc_sample_output(self):
        output = [
            'Generate Time:       0.41289',
            'Build Time:          1.89460',
            'Graph has 1048576 nodes and 16776968 undirected edges for degree: 15',
            '    a                0.00035',
            'source: 209629',
            '    b                0.45253',
            '    p                0.31504',
            'Trial Time:          0.76991',
            'Average Time:        0.76991',
        ]
        metrics = self.parser.parse(output, None, 0)
        self.assertDictEqual({
                'generate_time': 0.41289,
                'build_time': 1.89460,
                'trial_time': 0.76991,
                'average_time': 0.76991,
            }, metrics)

    def test_bfs_sample_ouput(self):
        output = [
            'Generate Time:       0.41075',
            'Build Time:          1.89220',
            'Graph has 1048576 nodes and 16776968 undirected edges for degree: 15',
            'Source:               209629',
            '    i                0.00086',
            '   td         29     0.00003',
            '   td        872     0.00002',
            '   td      27534     0.00049',
            '   td     579473     0.01030',
            '    e                0.00445',
            '   bu     440667     0.01020',
            '   bu          0     0.00044',
            '    c                0.00073',
            'Trial Time:          0.02800',
            'Average Time:        0.02800',
        ]
        metrics = self.parser.parse(output, None, 0)
        self.assertDictEqual({
                'generate_time': 0.41075,
                'build_time': 1.89220,
                'trial_time': 0.02800,
                'average_time': 0.02800,
            }, metrics)

    def test_tc_sample_output(self):
        output = [
            'Generate Time:       0.40949',
            'Build Time:          1.88401',
            'Graph has 1048576 nodes and 16776968 undirected edges for degree: 15',
            'Trial Time:          2.45414',
            'Average Time:        2.45414',
        ]
        metrics = self.parser.parse(output, None, 0)
        self.assertDictEqual({
                'generate_time': 0.40949,
                'build_time': 1.88401,
                'trial_time': 2.45414,
                'average_time': 2.45414,
            }, metrics)


if __name__ == '__main__':
    unittest.main()
