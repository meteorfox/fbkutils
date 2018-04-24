#!/usr/bin/env python3
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import unittest
from unittest import mock

from benchpress.lib.job import Job
from benchpress.plugins.hooks.toplev import Toplev


class TestToplevHook(unittest.TestCase):

    def setUp(self):
        self.hook = Toplev()
        self.job_config = {
            'name': 'schbench',
            'description': 'defaults for schbench',
            'args': {
                'message-threads': '2',
                'threads': '16',
                'runtime': '30',
                'sleeptime': '10000',
                'cputime': '10000',
                'pipe': '0',
                'rps': '0',
            },
            'hooks': [
                {
                    'hook': 'toplev',
                },
            ],
        }
        self.benchmark_config = {
            'parser': 'schbench',
            'path': './benchmarks/schbench',
            'metrics': {
                'latency': [
                    'p50',
                    'p75',
                    'p90',
                    'p95',
                    'p99',
                    'p99.5',
                    'p99.9',
                ]
            }
        }

    def test_default_toplev(self):
        job = Job(self.job_config, self.benchmark_config)
        self.hook.before_job({}, job)
        self.assertEqual('toplev.py', job.binary)
        expected_args = [
            '-l1',  # Level
            '-I100',
            '--summary',
            '-m',  # Extra metrics
            '--no-desc',
            '-x,',
            '-o', 'toplev_output.csv',
            '--',
            './benchmarks/schbench',
            '--message-threads', '2',
            '--threads', '16',
            '--runtime', '30',
            '--sleeptime', '10000',
            '--cputime', '10000',
            '--pipe', '0',
            '--rps', '0',
        ]
        self.assertEqual(expected_args, job.args)

    @mock.patch('benchpress.lib.util.issue_background_command')
    def test_background_mode_toplev(self, issue_background_command):
        opts = {
            'background_mode': {'duration': '120'},
        }
        job_config_hook = {
            'hook': 'toplev',
            'options': opts,
        }
        self.job_config['hooks'][0] = job_config_hook
        job = Job(self.job_config, self.benchmark_config)
        self.hook.before_job(opts, job)
        issue_background_command.assert_called_once_with(
            ['toplev.py', '-l1', '-I100', '--summary', '-m', '--no-desc',
             '-x,', '-o', 'toplev_output.csv', '--', 'sleep', '120'],
            'toplev_stdout.log',
            'toplev_stderr.log'
        )

    def test_override_toplev_binary_path(self):
        opts = {'binary_path': '/bin/toplev'}
        job_config_hook = {
            'hook': 'toplev',
            'options': opts,
        }
        self.job_config['hooks'][0] = job_config_hook
        job = Job(self.job_config, self.benchmark_config)
        self.hook.before_job(opts, job)
        self.assertEqual('/bin/toplev', job.binary)

    @mock.patch('benchpress.lib.util.issue_background_command')
    def test_override_toplev_stdout_stderr(self, issue_background_command):
        opts = {
            'background_mode': {
                'duration': '120',
                'stdout_path': '/root/stdout.log',
                'stderr_path': '/root/stderr.log',
            },
        }
        job_config_hook = {
            'hook': 'toplev',
            'options': opts,
        }
        self.job_config['hooks'][0] = job_config_hook
        job = Job(self.job_config, self.benchmark_config)
        self.hook.before_job(opts, job)
        issue_background_command.assert_called_once_with(
            ['toplev.py', '-l1', '-I100', '--summary', '-m', '--no-desc',
             '-x,', '-o', 'toplev_output.csv', '--', 'sleep', '120'],
            '/root/stdout.log',
            '/root/stderr.log',
        )


if __name__ == '__main__':
    unittest.main()
