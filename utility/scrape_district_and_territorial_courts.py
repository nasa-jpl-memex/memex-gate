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
    parser = ArgumentParser(description='Grabs all regions from List of United States district and territorial courts')
    parser.add_argument('-u', '--url', required=False, default='http://en.wikipedia.org/wiki/List_of_United_States_district_and_territorial_courts', help='url to grab from')
    args = parser.parse_args()
    return args


def parse_rows(rows):
    """ Get data from rows """
    results = []
    for row in rows:
        if row.find('td'):
            row_first_column = row.find_all('td')[0]
            if row_first_column.get_text():
                results.append(row_first_column.get_text().split('!')[1])
    return results


def main():
    '''
    Purpose::
        Fetches
        http://en.wikipedia.org/wiki/List_of_United_States_district_and_territorial_courts
        and uses XPATH to extract out Regions
        from United States district and territorial courts
        The data is then written to a flat file one region per
        line.
    Input::
    
    Output::
    
    Assumptions::
    '''
    # Get arguments
    args = parse_arguments()
    if args.url:
        url = args.url

    # Make soup
    try:
        resp = urlopen(url)
    except URLError as e:
        print 'An error occured fetching %s \n %s' % (url, e.reason)   
        return 1
    soup = BeautifulSoup(resp.read())

    # Get table
    try:
        table = soup.find_all('table')[3]
    except AttributeError as e:
        print 'No tables found, exiting'
        return 1

    # Get rows
    try:
        rows = table.find_all('tr')
    except AttributeError as e:
        print 'No table rows found, exiting'
        return 1

    # Get data
    table_data = parse_rows(rows)

    f = open('US_district_and_territorial_courts.txt', 'w')
    # Print data
    #f.write("\n".join(str(i).encode('utf8') for i in table_data))
    for i in table_data:
        f.write((i).encode('utf8') +'\n')

    f.close()
       
    #write data to flat file


if __name__ == '__main__':
    status = main()
    sys.exit(status)

