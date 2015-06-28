reg = r/((january|february|march|april|may|june|july|august|september|october|november|december)(?=[\W$])|(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(?=[\W$])|(1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th|11th|12th|13th|14th|15th|16th|17th|18th|19th|20th|21st|22nd|23rd|24th|25th|26th|27th|28th|29th|30th|31st)|(\d+)|.+?)/gi
months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

extractDates (string, now) =
  [
    chain <- chainsInMatches (string.match(reg) || [])
    d = dateFromChain (chain, now || @new Date)
    d != nil
    @new PartialDate (d.0, d.1, d.2, chain)
  ]

chainsInMatches (matches) =
  c = [], chains = [], delim = false, inDate = false

  nextChain () =
    if (c.length > 0) @{ chains.push (c) }
    c := []

  for each @(word) in (matches)
    if (isDatePart(word))
      if (inDate)
        nextChain()
      else
        c.push (word)
        inDate := true
    else if (inDate)
      inDate := false
      if (c.length == 1)
        delim := word
      else if (word != delim)
        nextChain()
    else
      nextChain()

  nextChain()
  chains

dateFromChain (chain, now) =
  validate (reorder (parse (tokenise (chain), now)))

PartialDate (y, m, d, chain) =
  if (y) @{ this.year = y, if (m) @{ this.month = m, if (d) @{ this.day = d } } }
  this.chain = chain
  this

PartialDate.prototype.format () =
  s = ''
  if (this.year)
    s := s + pad(this.year, 4)
    if (this.month)
      s := s + '-' + pad (this.month, 2)
      if (this.day)
        s := s + '-' + pad (this.day, 2)

  s

pad (s, n) =
  p = s.toString()
  while (p.length < n) @{ p := '0' + p }
  p

tokenise (chain) =
  [
    word <- chain
    { word = word, type = tokenType (word), value = tokenValue (word) }
  ]

tokenType (word) =
  if (word.match(r/^\d\d\d\d+$/))
    'year'
  else if (word.match(r/^\d+$/))
    'number'
  else if (word.match(r/\d/))
    'day'
  else
    'month'

tokenValue (word) =
  Number(word.replace(r/\D/g, '')) @or \
    months.indexOf(word.substring(0, 3).toLowerCase()) + 1

parse (tokens, now) =
  relativeYear (year) = nearestYear (year, now)
  t0 = tokens.0, t1 = tokens.1, t2 = tokens.2
  if (tokens.length == 3)
    if (t0.type == 'year')
      [t0.value, t1.value, t2.value]
    else if (t2.type == 'year')
      [t2.value, t1.value, t0.value]
    else if (t0.type == 'month')
      [t2.value, t0.value, t1.value]
    else if (t0.type == 'day')
      [relativeYear (t2.value), t1.value, t0.value]
    else if (t0.value > 31)
      [relativeYear (t0.value), t1.value, t2.value]
    else
      [relativeYear (t2.value), t1.value, t0.value]
  else if (tokens.length == 2)
    if (t0.type == 'month')
      [relativeYear (t1.value), t0.value]
    else if (t1.type == 'month')
      [t0.value, t1.value]
    else if (t0.type == 'year')
      [t0.value, t1.value]
    else
      [relativeYear (t1.value), t0.value]
  else if (tokens.length == 1)
    if (t0.type == 'year' @or (t0.type == 'number' @and t0.value > 0))
      [t0.value]

nearestYear (year, now) =
  if (year > 0 @and year < 100)
    thisYear = now.getFullYear()
    century = Math.floor(thisYear / 100)
    x = ((century - 1) * 100) + year
    y = (century * 100) + year
    z = ((century + 1) * 100) + year
    xd = Math.abs(x - thisYear)
    yd = Math.abs(y - thisYear)
    zd = Math.abs(z - thisYear)
    k = Math.min(xd, yd, zd)
    if (k == xd)
      x
    else if (k == zd)
      z
    else
      y
  else
    year

reorder (d) =
  if (d)
    if (d @and d.length == 3 @and d.1 > 12)
      [d.0, d.2, d.1]
    else if (d @and (d.length == 2 @and d.1 > 12) @or (d.length == 1 @and d.0 < 999))
      nil
    else
      d

validate (d) =
  if (d @and (@not (
      (d.length > 1 @and (d.1 < 1 @or d.1 > 12)) @or (
       d.length > 2 @and (d.2 < 1 @or d.2 > 31)))))
    d

isDatePart (t) = t :: String @and (t.length > 1 @or t.match r/\d/)

module.exports = extractDates
