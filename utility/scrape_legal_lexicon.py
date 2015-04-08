#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#ITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

import sys
import re
from argparse import ArgumentParser

from pyth.plugins.rtf15.reader import Rtf15Reader
from pyth.plugins.plaintext.writer import PlaintextWriter

import itertools

def parse_arguments():
    """ Process command line arguments """
    parser = ArgumentParser(description='convert legal lexicon in RTF to a text file list of terms one per line')
    parser.add_argument('-u', '--url', required=True, help='absolute path the legal_lexicon.rtf file')
    args = parser.parse_args()
    return args


def extract_terms(rtffile):
    """ Get data from rtffile """
    judges_list = []
    rtf_text = PlaintextWriter.write(rtffile).getvalue()
    lines = re.split('\n',rtf_text)
    for line in itertools.islice(lines, 0, None, 4): # 1: from the second line ([1]), 
        judges_list.append(line)              # None: to the end,
    return judges_list                                  # 2: step




def main():
    '''
    Purpose::

    Input::
    
    Output::
    
    Assumptions::
    '''
    # Get arguments
    args = parse_arguments()
    if args.url:
        url = args.url

    # Get file and read it into structure
    try:
        with open(url, 'rb') as rtffile:
            judges = extract_terms(Rtf15Reader.read(rtffile))
            #print PlaintextWriter.write(doc).getvalue()
                
    except IOError as e:
        print 'An error occured fetching %s \n %s' % (url, e.reason)   
        return 1

    f = open('US_legal_lexicon.txt', 'w')
    # Print data
    #f.write("\n".join(str(i).encode('utf8') for i in judges))
    for i in judges:
        f.write((i).encode('utf8') +'\n')

    f.close()


if __name__ == '__main__':
    status = main()
    sys.exit(status)

