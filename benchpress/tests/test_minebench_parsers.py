# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import os
import unittest

from benchpress.plugins.parsers.minebench import (
    KMeansParser,
    PLSAParser,
    RSearchParser,
)


class TestKMeansParser(unittest.TestCase):
    def setUp(self):
        self.stderr = [
            'real 2.00',
            'user 1.50',
            'sys 0.02',
        ]
        self.parser = KMeansParser()

    def test_parse_expected_output(self):
        metrics = self.parser.parse(None, self.stderr, 0)
        self.assertTrue('execution_time' in metrics)
        self.assertDictEqual({
            'real': 2.0,
            'user': 1.5,
            'sys': 0.02,
        }, metrics['execution_time'])


class TestPLSAParser(unittest.TestCase):
    def setUp(self):
        output_path = os.path.join(
            os.path.dirname(__file__),
            'data',
            'plsa_output.txt'
        )
        with open(output_path, 'r') as f:
            self.stdout = f.readlines()
        self.parser = PLSAParser()

    def test_parse_expected_output(self):
        metrics = self.parser.parse(self.stdout, None, 0)
        self.assertTrue('execution_time' in metrics)
        self.assertDictEqual({'total_time': 43.69}, metrics['execution_time'])


class TestRSearchParser(unittest.TestCase):
    def setUp(self):
        output_path = os.path.join(
            os.path.dirname(__file__),
            'data',
            'rsearch_output.txt'
        )
        with open(output_path, 'r') as f:
            self.stdout = f.readlines()
        self.parser = RSearchParser()

    def test_parse_expected_output(self):
        metrics = self.parser.parse(self.stdout, None, 0)
        self.assertTrue('execution_time' in metrics)
        self.assertDictEqual({'total_time': 225.7}, metrics['execution_time'])


if __name__ == '__main__':
    unittest.main()
