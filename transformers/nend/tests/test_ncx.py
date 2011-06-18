#!/usr/bin/env python
# encoding: utf-8
'''
test_ncx.py

Created by Keith Fahlgren on Fri Jun 17 21:42:52 PDT 2011
Copyright (c) 2011 Threepress Consulting Inc. All rights reserved.
'''

import difflib
import glob
import logging
import os.path

from nose.tools import *

from lxml import etree


import nend
import nend.ncx


log = logging.getLogger(__name__)


class TestNCX(object):
    def setup(self):
        self.testfiles_dir = os.path.join(os.path.dirname(__file__), 'files')

    def test_ncx_end_output_same_smoke(self):
        '''An EPUB Navigation Document transformed from an NCX document should match the expected result'''
        for ncx_fn in glob.glob(self.testfiles_dir + '/expected*.ncx'):
            ncx_docname, _ = os.path.splitext(os.path.basename(ncx_fn))
            expected_end_fn = os.path.join(self.testfiles_dir, ncx_docname + '.html')
            expected_end = etree.parse(expected_end_fn)

            ncx = etree.parse(ncx_fn)
            end = nend.ncx.as_end(ncx)
            # Ensure the output is valid before testing the exact representation
            assert(nend.validate(end))
            try:
                assert_equal(etree.tostring(expected_end), etree.tostring(end))
            except AssertionError:
                try:
                    pretty_expected_end = etree.tostring(expected_end, pretty_print=True)
                    pretty_end = etree.tostring(end, pretty_print=True)
                    assert_equal(pretty_expected_end, pretty_end)
                except AssertionError:
                    # This is an absurd oneliner to keep the nose detailed-errors
                    # output small
                    diff = '\n'.join(list(difflib.unified_diff(pretty_expected_end.splitlines(),
                                                               pretty_end.splitlines())))
                    raise AssertionError('XML documents for %s did not match. Diff:\n%s' % (ncx_docname, diff))

    def test_xhtml_nend_output_valid_smoke(self):
        '''All NCX documents collected for smoketesting should be able to be transformed into a valid EPUB Navigation Document'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'smoketests')
        for ncx_fn in glob.glob(smoketests_dir + '/*.ncx'):
            log.debug('\nSmoke testing transformation and validation of %s' % ncx_fn)
            ncx = etree.parse(ncx_fn)
            end = nend.ncx.as_end(ncx)
            assert(nend.validate(end))


