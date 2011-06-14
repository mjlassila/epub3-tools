from setuptools import setup, find_packages
import sys, os

version = '0.1'

setup(name='nend',
      version=version,
      description="nend transforms EPUB NCX documents into EPUB 3 Navigation Documents",
      long_description="""\
""",
      classifiers=[], # Get strings from http://pypi.python.org/pypi?%3Aaction=list_classifiers
      keywords='epub',
      author='Keith Fahlgren',
      author_email='keith@threepress.org',
      url='http://threepress.org',
      license='BSD',
      packages=find_packages(exclude=['ez_setup', 'examples', 'tests']),
      package_data = { 'nend.externals': ['schemas/epub3/*.*',
                                          'schemas/epub3/mod/*.*',
                                          'xslt/*.*',
                                         ],
                     },
      include_package_data=True,
      zip_safe=False,
      install_requires=[
          # -*- Extra requirements: -*-
          'lxml >= 2.2'
      ],
      entry_points="""
      # -*- Entry points: -*-
      """,
      )
