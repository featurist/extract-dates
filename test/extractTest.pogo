expect = require 'chai'.expect
datesIn = require '../index'

describe 'extract-dates'

  it finds (dates) in (string) when today is (now) =
    it "finds #((dates.join ' and ') || 'no dates') in '#(string)'"
      expect ([d <- datesIn(string, @new Date(now)), d.format()]).to.eql (dates)

  it finds (dates) in (string) =
    it finds (dates) in (string) when today is '2000-01-01'

  describe 'finding no dates'

    it finds [] in ''
    it finds [] in '22-000'
    it finds [] in '14/15/2016'
    it finds [] in '32/09/1970'
    it finds [] in '0/07/1977'
    it finds [] in '10/0/1974'
    it finds [] in '1/2/3/4'
    it finds [] in '1999-12-12-12'
    it finds [] in '01/02/03/1966'

  describe 'finding dates with digits'

    it finds ['2015'] in '2015'
    it finds ['1066-10'] in '1066-10'
    it finds ['2030-12'] in '12-30'
    it finds ['2010-11'] in '11-10'
    it finds ['1901-12-29'] in 'on 1901-12-29'
    it finds ['2020-02-01'] in '1/2/2020 or later'
    it finds ['1234-12-30'] in '30.12.1234'
    it finds ['20095-12-12'] in '12-12-20095'
    it finds ['0001-05-04'] in '4-5-0001'
    it finds ['1995-12-13'] in '13/12/95'
    it finds ['2005-04-05'] in '05/04/05'
    it finds ['1997-06'] in '1997-06/11'
    it finds ['1945-06'] in '06/1945'
    it finds ['2007-11'] in '11/07'
    it finds ['2006-05-13'] in '05/13/2006'

  describe 'finding dates with month names'

    it finds ['2000-03'] in 'MARCH 2000'
    it finds ['1994-05'] in 'May 94'
    it finds ['2012-02'] in 'feb 2012'
    it finds ['1978-09'] in 'sep 78'
    it finds ['1999-12-31'] in '31 December 1999'
    it finds ['1996-05-24'] in '24th May 1996'
    it finds ['1901-06-01'] in '1st june 1901'
    it finds ['2012-07-02'] in '2nd jul 12'

  describe 'when there are multiple dates'

    it finds ['2012-12-12', '2011-11-11', '2033-03'] in '12/12/2012 or 11.nov.2011 or 2033/03'
    it finds ['2015', '2016'] in 'some day in 2015 or maybe 2016'
    it finds ['2001-01-01', '1996-01-01'] in '2001-01-01 Jan 1996'
    it finds ['2020', '2021-12'] in 'Some day in 2020 or dec 2021'
    it finds ['2001-09-21', '2001-01-01'] in '21st sep 2001-01-01'

  describe 'finding dates relative to another year'

    it finds ['2120-02-03'] in '3rd Feb 20' when today is '2119-12-12'
    it finds ['2207-12-03'] in '3rd Dec 07' when today is '2209-01-03'
    it finds ['2018-04-05'] in '05/04/18' when today is '2018-05-04'

  it 'includes the chain of date components used to recognise each date'
    chains = [date <- datesIn('1969-09-28 or feb 1968'), date.chain]
    expect(chains).to.eql [
      ['1969', '09', '28']
      ['feb', '1968']
    ]
