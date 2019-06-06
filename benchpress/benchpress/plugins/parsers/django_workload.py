# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

import logging
import re

from benchpress.lib.parser import Parser

logger = logging.getLogger(__name__)

def DjangoWorkloadParser(Parser):
    """Example output:
    URL hit percentages:
    /bundle_tray:       0.0%, expected 25%
    /timeline:      0.0%, expected 25%
    /inbox:         0.0%, expected 19%
    /seen:          0.0%, expected 5%
    /feed_timeline:     0.0%, expected 26%

    Transactions:               0.0 hits ---- RSD 0
    Availability:               0.0 % ---- RSD 0
    Elapsed time:               0.078 secs ---- RSD 0.125614858604
    Data transferred:           0.0 MB ---- RSD 0
    Response time:              0.0 secs ---- RSD 0
    Transaction rate:           0.0 trans/sec ---- RSD 0
    Throughput:             0.0 MB/sec ---- RSD 0
    Concurrency:                0.0  ---- RSD 0
    Successful transactions:        0.0  ---- RSD 0
    Failed transactions:            1167.0  ---- RSD 0.0
    Longest transaction:            0.0  ---- RSD 0
    Shortest transaction:           0.0  ---- RSD 0
    P50:                    N/A, please check Siege output file(s)
    P90:                    N/A, please check Siege output file(s)
    P95:                    N/A, please check Siege output file(s)
    P99:                    N/A, please check Siege output file(s)
    """

    def parse_dw_data(line):
        line = line.split(':')
        for i in range(0, len(line)):
            line[i] = line[i].strip()
        metric = line[0]
        data = line[1]

        url_pattern = re.compile('/([a-z])*)')

        if url_pattern.match(metric) is not None:
            dw_output['URL hit percentages'][metric] = data
        else:
            dw_output[metric] = data

        return (metric, data)

    # TODO: Use lazy evaluation to parse file; don't load whole file into
    # memory
    def parse(self, stdout, stderr, returncode):
        dw_output_file = open(stdout, 'r')
        dw_output_lines = dw_output_file.readlines()

        # Find first line of URL hit percentages and only begin parsing data
        # from there
        dw_output_first_idx = [line_idx for line_idx,line in enumerate(
                                dw_output_lines) if 'URL hit' in line][0]
        if dw_output_first_idx == None:
            logger.error('File "{}" does not have a line denoting URL hit\
                         percentage'.format(stdout))
            raise ValueError('File "{}" does not have line denoting URL \
                                 hit percentages'.format(stdout))
        dw_output_lines = dw_output_lines[dw_output_first_idx:]

        dw_output = {}
        for line in dw_output_lines:
            if 'URL' in line:
                dw_output['URL hit percentages'] = {}
                continue

            if not line.isalnum(): # Skip empty or non-interpretable lines
                continue

            if ':' in line:
                metric, data = parse_dw_data(line)
                dw_output[metric] = data

        dw_output_file.close()
        return dw_output
