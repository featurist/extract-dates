# extract-dates

Finds dates in strings where date formats are varied and unpredictable.

```JavaScript
var extractDates = require('extract-dates');

extractDates("1945/05/04-12/23/99, jan 2001 or 2015");

/*
  produces:

  [
    { year: 1945, month: 5, day: 4 },
    { year: 1999, month: 12, day: 23 },
    { year: 2001, month: 1 },
    { year: 2015 }
  ]
*/
```

### Install

```
npm install extract-dates
```

### License

BSD
