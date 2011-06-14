#!/usr/bin/env python
# encoding: utf-8
'''
test_nend.py

Created by Keith Fahlgren on Mon Jun 13 16:12:29 PDT 2011
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


class TestNend(object):
    def setup(self):
        self.testfiles_dir = os.path.join(os.path.dirname(__file__), 'files')

    def test_end_valid(self): 
        '''An EPUB Navigation Document document should be able to be successfully validated'''
        valid_end_fn = os.path.join(self.testfiles_dir, 'good.nav.html')
        valid_end = etree.parse(valid_end_fn)
        assert(nend.validate(valid_end))

    def test_end_not_valid_rnc(self): 
        '''An EPUB Navigation Document with RELAX NG errors should not be able to be successfully validated'''
        not_valid_end_fn = os.path.join(self.testfiles_dir, 'invalid.rnc.html')
        not_valid = etree.parse(not_valid_end_fn)
        assert(not(nend.validate(not_valid)))

    def test_end_not_valid_sch(self): 
        '''An EPUB Navigation Document with Schematron errors should not be able to be successfully validated'''
        not_valid_end_fn = os.path.join(self.testfiles_dir, 'invalid.sch.html')
        not_valid = etree.parse(not_valid_end_fn)
        assert(not(nend.validate(not_valid)))

    def test_all_invalid(self):
        '''All invalid EPUB Navigation Documents from the IDPF should not be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'invalid')
        for end_fn in glob.glob(smoketests_dir + '/*.html'):
            not_valid = etree.parse(end_fn)
            assert(not(nend.validate(not_valid)))

    def test_all_valid(self):
        '''All valid EPUB Navigation Documents from the IDPF should be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'valid')
        for end_fn in glob.glob(smoketests_dir + '/*.html'):
            valid = etree.parse(end_fn)
            assert(nend.validate(valid))



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

