#!/usr/bin/env python3
# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import logging

from benchpress.lib.hook import Hook
from benchpress.lib import util

logger = logging.getLogger(__name__)


DEFAULT_BACKGROUND_DURATION_SECS = '300'
DEFAULT_STDOUT_PATH = 'toplev_stdout.log'
DEFAULT_STDERR_PATH = 'toplev_stderr.log'
DEFAULT_TOPLEV_OUTPUT_CSV_PATH = 'toplev_output.csv'
DEFAULT_OPTIONS = [
    '-l1',  # Level
    '-I100',
    '--summary',
    '-m',  # Extra metrics
    '--no-desc',
    '-x,',
    '-o', DEFAULT_TOPLEV_OUTPUT_CSV_PATH,
]

DEFAULT_PATH = 'toplev.py'


class Toplev(Hook):
    """Collect `toplev` counters during a job.

        - `hook`:
          `options`:
            `args`: list of str - command line arguments to pass to toplev
            `background_mode`:
              `duration`: int or string
              `stdout_path`: str - file path to write stdout of background cmd
              `stderr_path`: str - file path to write stderr of background cmd
            `binary_path`: str - location of toplev command
    """

    def before_job(self, opts, job):
        if not opts:
            opts = {'args': DEFAULT_OPTIONS}
        if 'args' not in opts:
            opts['args'] = DEFAULT_OPTIONS

        if 'background_mode' in opts and opts['background_mode']:
            self._start_background_toplev(opts)
        else:
            binary_path = job.config['path']
            job.args = opts['args'] + ['--', binary_path] + job.args
            job.binary = opts.get('binary_path', DEFAULT_PATH)

    def after_job(self, opts, job):
        # Do nothing
        pass

    def _start_background_toplev(self, opts):
        bg_opts = opts['background_mode']
        duration = bg_opts.get('duration', DEFAULT_BACKGROUND_DURATION_SECS)
        stdout_path = bg_opts.get('stdout_path', DEFAULT_STDOUT_PATH)
        stderr_path = bg_opts.get('stderr_path', DEFAULT_STDERR_PATH)
        cmd = [opts.get('binary_path', DEFAULT_PATH)]
        cmd += opts['args']
        cmd += ['--', 'sleep', duration]
        util.issue_background_command(cmd, stdout_path, stderr_path)
