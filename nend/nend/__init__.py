#!/usr/bin/env python
# encoding: utf-8
"""
__init__.py

Created by Keith Fahlgren on Mon Jun 13 16:17:48 PDT 2011
Copyright (c) 2011 Threepress Consulting Inc. All rights reserved.
"""

import logging
import os.path
import subprocess
import tempfile


from lxml import etree

log = logging.getLogger(__name__)


JING_FN = os.path.join(os.path.dirname(__file__), 
                       'externals', 
                       'jing', 
                       'jing.jar') 

NAV_RNC = os.path.join(os.path.dirname(__file__), 
                       'externals', 
                       'schemas',
                       'epub3',
                       'epub-nav-30.rnc')

NSS={'svrl': "http://purl.oclc.org/dsdl/svrl",
    }

SCH_XSL = os.path.join(os.path.dirname(__file__), 
                       'externals', 
                       'schemas',
                       'epub3',
                       'epub-nav-30.sch.xsl')

def validate(nav_doc):
    """Validate the supplied EPUB Navigation Document (as etree) against the RELAX NG Compact and Schematron schemas. Returns boolean. Writes warnings
       to this classes' log stream."""
    jing_result = jing_validate(nav_doc, NAV_RNC)
    sch_result = schematron_validate(nav_doc, SCH_XSL)
    return (jing_result and sch_result)

def jing_validate(xml, rnc_fn):
    fd, tmp_fn = tempfile.mkstemp()
    f = os.fdopen(fd, 'wb')
    result = False
    try:
        f.write(etree.tostring(xml))
        f.close()

        jing_cmd = ['java', '-jar', JING_FN, '-c', rnc_fn, tmp_fn]
        process = subprocess.Popen(jing_cmd, stdout=subprocess.PIPE)
        output, _ = process.communicate()
        retcode = process.poll()
        if retcode != 0:
            log.warn('Validation errors:\n%s' % output)
        else:
            result = True

    finally:
        os.remove(tmp_fn)
        return result

def schematron_validate(xml, sch_xsl_fn):
    svrl_validation_results = etree.XSLT(etree.parse(sch_xsl_fn))
    svrl = svrl_validation_results(xml)
    errors = []

    for svrl_error in svrl.xpath('//svrl:failed-assert/svrl:text/text()|//svrl:successful-report/svrl:text/text()',
                                 namespaces=NSS):
        errors.append('SVRL Error: %s' % svrl_error)
    if len(errors) == 0:
        return True
    else:
        for error in errors:
            log.warn(error)
        return False
