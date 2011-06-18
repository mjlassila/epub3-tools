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
        '''An EPUB Navigation Document should be able to be successfully validated'''
        valid_end_fn = os.path.join(self.testfiles_dir, 'good.nav.html')
        valid_end = etree.parse(valid_end_fn)
        assert(nend.nav_validate(valid_end))

    def test_end_not_valid_rnc(self): 
        '''An EPUB Navigation Document with RELAX NG errors should not be able to be successfully validated'''
        not_valid_end_fn = os.path.join(self.testfiles_dir, 'invalid.rnc.html')
        not_valid = etree.parse(not_valid_end_fn)
        assert(not(nend.nav_validate(not_valid)))

    def test_end_not_valid_sch(self): 
        '''An EPUB Navigation Document with Schematron errors should not be able to be successfully validated'''
        not_valid_end_fn = os.path.join(self.testfiles_dir, 'invalid.sch.html')
        not_valid = etree.parse(not_valid_end_fn)
        assert(not(nend.nav_validate(not_valid)))

    def test_end_all_invalid(self):
        '''All invalid EPUB Navigation Documents from the IDPF should not be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'invalid')
        for end_fn in glob.glob(smoketests_dir + '/*.html'):
            not_valid = etree.parse(end_fn)
            assert(not(nend.nav_validate(not_valid)))

    def test_end_all_valid(self):
        '''All valid EPUB Navigation Documents from the IDPF should be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'valid')
        for end_fn in glob.glob(smoketests_dir + '/*.html'):
            valid = etree.parse(end_fn)
            assert(nend.nav_validate(valid))


# ===============

    def test_packdoc_valid(self): 
        '''A Publication Document should be able to be successfully validated'''
        valid_packdoc_fn = os.path.join(self.testfiles_dir, 'good.package.opf')
        valid_end = etree.parse(valid_packdoc_fn)
        assert(nend.package_validate(valid_end))

    def test_packdoc_not_valid_rnc(self): 
        '''A Publication Document with RELAX NG errors should not be able to be successfully validated'''
        not_valid_packdoc_fn = os.path.join(self.testfiles_dir, 'invalid.package.rnc.opf')
        not_valid = etree.parse(not_valid_packdoc_fn)
        assert(not(nend.package_validate(not_valid)))

    def test_packdoc_not_valid_sch(self): 
        '''An Publication Document with Schematron errors should not be able to be successfully validated'''
        not_valid_packdoc_fn = os.path.join(self.testfiles_dir, 'invalid.package.sch.opf')
        not_valid = etree.parse(not_valid_packdoc_fn)
        assert(not(nend.package_validate(not_valid)))

    def test_packdoc_all_invalid(self):
        '''All invalid Publication Documents from the IDPF should not be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'invalid', 'package')
        for end_fn in glob.glob(smoketests_dir + '/*.opf'):
            not_valid = etree.parse(end_fn)
            assert(not(nend.package_validate(not_valid)))

    def test_packdoc_all_valid(self):
        '''All valid Publication Documents from the IDPF should be able to be successfully validated'''
        smoketests_dir = os.path.join(self.testfiles_dir, 'valid', 'package')
        for end_fn in glob.glob(smoketests_dir + '/*.opf'):
            valid = etree.parse(end_fn)
            assert(nend.package_validate(valid))


# ===============
