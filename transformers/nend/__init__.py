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


from lxml import etree, isoschematron

log = logging.getLogger(__name__)


JING_FN = os.path.join(os.path.dirname(__file__), 
                       'externals', 
                       'jing', 
                       'jing.jar') 
SAXON_FN = os.path.join(os.path.dirname(__file__), 
                        'externals', 
                        'saxon', 
                        'saxon9he.jar') 


SCHEMAS = os.path.join(os.path.dirname(__file__), 
                       'externals', 
                       'schemas',
                       'epub3')
NAV_RNC = os.path.join(SCHEMAS, 'epub-nav-30.rnc')
NAV_SCH_FN = os.path.join(SCHEMAS, 'epub-nav-30.sch')
NAV_SCHEMATRON = isoschematron.Schematron(etree.parse(NAV_SCH_FN), store_report=True)
PACKAGE_RNC = os.path.join(SCHEMAS, 'package-30.rnc')
PACKAGE_SCH_XSL = os.path.join(SCHEMAS, 'package-30.sch.xsl')

NSS={'svrl': "http://purl.oclc.org/dsdl/svrl",
    }


def nav_validate(nav_doc):
    """Validate the supplied EPUB Navigation Document (as etree) against the RELAX NG Compact and Schematron schemas. Returns boolean. Writes warnings
       to this classes' log stream."""
    jing_result = jing_validate(nav_doc, NAV_RNC)
    sch_result = schematron_xslt1_validate(nav_doc, NAV_SCHEMATRON)
    return (jing_result and sch_result)

def package_validate(package_doc):
    """Validate the supplied EPUB Navigation Document (as etree) against the RELAX NG Compact and Schematron schemas. Returns boolean. Writes warnings
       to this classes' log stream."""
    jing_result = jing_validate(package_doc, PACKAGE_RNC)
    sch_result = schematron_xslt2_validate(package_doc, PACKAGE_SCH_XSL)
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

def schematron_xslt1_validate(xml, validator):
    result = validator.validate(xml)
    if result:
        return True
    else:
        svrl_doc = validator.validation_report
        errors = _collect_svrl_errors(svrl_doc)
        for error in errors:
            log.warn(error)
        return False

def schematron_xslt2_validate(xml, sch_xsl_fn):
    fd, tmp_fn = tempfile.mkstemp()
    f = os.fdopen(fd, 'wb')
    svrl_doc = None
    try:
        f.write(etree.tostring(xml))
        f.close()

        saxon_cmd = ['java', '-jar', SAXON_FN, tmp_fn, sch_xsl_fn]
        log.debug("CS: %s" % saxon_cmd)
        process = subprocess.Popen(saxon_cmd, stdout=subprocess.PIPE)
        output, _ = process.communicate()
        retcode = process.poll()
        if retcode != 0:
            log.warn('Schematron processing errors:\n%s' % output)
        else:
            log.debug("OUT: %s" % output)
            svrl_doc = etree.fromstring(output)

    finally:
        os.remove(tmp_fn)

    errors = _collect_svrl_errors(svrl_doc)
    if len(errors) == 0:
        return True
    else:
        for error in errors:
            log.warn(error)
        return False

def _collect_svrl_errors(svrl_doc):
    errors = []
    for svrl_error in svrl_doc.xpath('//svrl:failed-assert/svrl:text/text()|//svrl:successful-report/svrl:text/text()',
                                     namespaces=NSS):
        errors.append('SVRL Error: %s' % svrl_error)
    return errors
