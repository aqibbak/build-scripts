#!/usr/bin/python

"""
Upload a file to S3
"""

from sys import argv, stdout
from time import time
from os.path import basename
from boto.s3.key import Key
from boto.s3.connection import S3Connection
def uploadFile( bucket, filename ):
    "Upload a file to a bucket"
    key = basename( filename )
    print '* Uploading', filename, 'to bucket', bucket, 'as', key
    stdout.flush()
    start = time()
    def callback( transmitted, size ):
        "Progress callback for set_contents_from_filename"
        elapsed = time() - start
        percent = 100.0 * transmitted / size
        kbps = .001 * transmitted / elapsed
        print ( '\r%d bytes transmitted of %d (%.2f%%),'
                ' %.2f KB/sec ' %
                ( transmitted, size, percent, kbps ) ),
        stdout.flush()
    conn = S3Connection()
    bucket = conn.get_bucket( bucket )
    k = Key( bucket )
    k.key = key
    k.set_contents_from_filename( filename, cb=callback, num_cb=100 )
    print
    elapsed = time() - start
    print "* elapsed time: %.2f seconds" % elapsed

if __name__ == '__main__':
    if len( argv ) != 3:
        print 'Usage: %s <bucket> <filename>'
        exit( 1 )
    bucket, filename = argv[ 1 : 3 ]
    uploadFile( bucket, filename )
