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
from urllib2 import urlopen, URLError
from argparse import ArgumentParser
from bs4 import BeautifulSoup

def parse_arguments():
    """ Process command line arguments """
    parser = ArgumentParser(description='Grabs list items from a collection of html pages')
    parser.add_argument('-u', '--url', required=False, default='http://www.topix.net/city/list/', help='url to grab from')
    args = parser.parse_args()
    return args


def parse_listItems(lis):
    """ Get data from lists """
    results = []
    for li in lis:
        for item in li:
            results.append(item.text[:item.text.index(',')])
    return results


def main():
    '''
    Purpose::
        scrape_us_cities.py merely fetches
        http://www.topix.net/city/list/
        and uses XPATH to extract out <li> which represents
        every U.S. city in the U.S.
        The script then grabs a particular node from the HTML tree which contains
        the next paginated result from which we iterate the program.
    Input::
    
    Output::
    
    Assumptions::
    '''
    f = open('us_cities.lst', 'a')
    for i in range(1, 26):
        if i > 1:
            try:
                domain = "http://www.topix.net/city/list/p" + str(i)
                print "fetching", domain
            except AttributeError as e:
                print 'Cannot locate any next page... exiting'
                return 1
        else:
            domain = "http://www.topix.net/city/list/"
            print "fetching", domain
    
        # Make soup
        try:
            resp = urlopen(domain)
            print "fetched and procesing", domain
        except URLError as e:
            print 'An error occured fetching %s \n %s' % (domain, e.reason)   
            return 1
        soup = BeautifulSoup(resp.read())

        # Get table
        try:
            uls = soup.findAll('ul', class_="dir_col")
        except AttributeError as e:
            print 'No unordered list items found, exiting'
            return 1

        # Get list items
        lis = []
        try:
            for ul in uls:
                lis.append(ul.findAll('li'))
        except AttributeError as e:
            print 'No list items found, exiting'
            return 1

        # Get data
        states = parse_listItems(lis)
        for i in set(states):
            f.write((i) +'\n') #.encode('utf8')

    f.close()
    print "written all states in %s to file," %domain

if __name__ == '__main__':

    status = main()
    sys.exit(status)
    

