#!/usr/bin/env python3

import logging

from benchpress.lib.hook import Hook

logger = logging.getLogger(__name__)


class Emon(Hook):
    """Emon hook allows the benchmark to collect CPU utilization data across
    execution time of application or system"""

    emon_proc = None

    def before_job(self, opts, job):
        self._start_background_emon(opts)

    def after_job(self, opts, job):
        util.kill_process(emon_proc)

    def _start_background_emon(self, opts):
        """Allows the emon data collection to happen in the background while
        application is executing"""

        cmd = ['./emon -i']
        try:
            cmd += opts['config_file']
        except:
            raise KeyError('Config file not specified in opts arg')
        stdout_path = bg_opts.get('stdout_path', DEFAULT_STDOUT_PATH)
        stderr_path = bg_opts.get('stderr_path', DEFAULT_STDERR_PATH)
        emon_proc = util.issue_background_command(
            cmd,
            stdout_path,
            stderr_path
        )

