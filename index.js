(function() {
    var self = this;
    var reg, months, extractDates, chainsInMatches, dateFromChain, PartialDate, pad, tokenise, tokenType, tokenValue, parse, nearestYear, reorder, validate, isDatePart;
    reg = /((january|february|march|april|may|june|july|august|september|october|november|december)(?=[\W$])|(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(?=[\W$])|(1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th|11th|12th|13th|14th|15th|16th|17th|18th|19th|20th|21st|22nd|23rd|24th|25th|26th|27th|28th|29th|30th|31st)|(\d+)|.+?)/gi;
    months = [ "jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec" ];
    extractDates = function(string, now) {
        return function() {
            var gen1_results, gen2_items, gen3_i, chain;
            gen1_results = [];
            gen2_items = chainsInMatches(string.match(reg) || []);
            for (gen3_i = 0; gen3_i < gen2_items.length; ++gen3_i) {
                chain = gen2_items[gen3_i];
                (function(chain) {
                    var d;
                    d = dateFromChain(chain, now || new Date());
                    if (d !== void 0) {
                        return gen1_results.push(new PartialDate(d[0], d[1], d[2], chain));
                    }
                })(chain);
            }
            return gen1_results;
        }();
    };
    chainsInMatches = function(matches) {
        var c, chains, delim, inDate, nextChain, gen4_items, gen5_i, word;
        c = [];
        chains = [];
        delim = false;
        inDate = false;
        nextChain = function() {
            if (c.length > 0) {
                chains.push(c);
            }
            return c = [];
        };
        gen4_items = matches;
        for (gen5_i = 0; gen5_i < gen4_items.length; ++gen5_i) {
            word = gen4_items[gen5_i];
            if (isDatePart(word)) {
                if (inDate) {
                    nextChain();
                } else {
                    c.push(word);
                    inDate = true;
                }
            } else if (inDate) {
                inDate = false;
                if (c.length === 1) {
                    delim = word;
                } else if (word !== delim) {
                    nextChain();
                }
            } else {
                nextChain();
            }
        }
        nextChain();
        return chains;
    };
    dateFromChain = function(chain, now) {
        return validate(reorder(parse(tokenise(chain), now)));
    };
    PartialDate = function(y, m, d, chain) {
        if (y) {
            this.year = y;
            if (m) {
                this.month = m;
                if (d) {
                    this.day = d;
                }
            }
        }
        this.chain = chain;
        return this;
    };
    PartialDate.prototype.format = function() {
        var self = this;
        var s;
        s = "";
        if (this.year) {
            s = s + pad(this.year, 4);
            if (this.month) {
                s = s + "-" + pad(this.month, 2);
                if (this.day) {
                    s = s + "-" + pad(this.day, 2);
                }
            }
        }
        return s;
    };
    pad = function(s, n) {
        var p;
        p = s.toString();
        while (p.length < n) {
            p = "0" + p;
        }
        return p;
    };
    tokenise = function(chain) {
        return function() {
            var gen6_results, gen7_items, gen8_i, word;
            gen6_results = [];
            gen7_items = chain;
            for (gen8_i = 0; gen8_i < gen7_items.length; ++gen8_i) {
                word = gen7_items[gen8_i];
                (function(word) {
                    return gen6_results.push({
                        word: word,
                        type: tokenType(word),
                        value: tokenValue(word)
                    });
                })(word);
            }
            return gen6_results;
        }();
    };
    tokenType = function(word) {
        if (word.match(/^\d+$/)) {
            return "number";
        } else if (word.match(/\d/)) {
            return "day";
        } else {
            return "month";
        }
    };
    tokenValue = function(word) {
        return Number(word.replace(/\D/g, "")) || months.indexOf(word.substring(0, 3).toLowerCase()) + 1;
    };
    parse = function(tokens, now) {
        var relativeYear, t0, t1, t2;
        relativeYear = function(year) {
            return nearestYear(year, now);
        };
        t0 = tokens[0];
        t1 = tokens[1];
        t2 = tokens[2];
        if (tokens.length === 3) {
            if (t0.word.length > 3) {
                return [ t0.value, t1.value, t2.value ];
            } else if (t2.word.length > 3) {
                return [ t2.value, t1.value, t0.value ];
            } else if (t0.type === "month") {
                return [ t2.value, t0.value, t1.value ];
            } else if (t0.type === "day") {
                return [ relativeYear(t2.value), t1.value, t0.value ];
            } else if (t0.value > 31) {
                return [ relativeYear(t0.value), t1.value, t2.value ];
            } else {
                return [ relativeYear(t2.value), t1.value, t0.value ];
            }
        } else if (tokens.length === 2) {
            if (t0.type === "month") {
                return [ relativeYear(t1.value), t0.value ];
            } else if (t1.type === "month") {
                return [ t0.value, t1.value ];
            } else if (t0.word.length > 2) {
                return [ t0.value, t1.value ];
            } else {
                return [ relativeYear(t1.value), t0.value ];
            }
        } else if (tokens.length === 1) {
            if (t0.type === "number" && t0.value > 0) {
                return [ t0.value ];
            }
        }
    };
    nearestYear = function(year, now) {
        var thisYear, century, x, y, z, xd, yd, zd, k;
        if (year > 0 && year < 100) {
            thisYear = now.getFullYear();
            century = Math.floor(thisYear / 100);
            x = (century - 1) * 100 + year;
            y = century * 100 + year;
            z = (century + 1) * 100 + year;
            xd = Math.abs(x - thisYear);
            yd = Math.abs(y - thisYear);
            zd = Math.abs(z - thisYear);
            k = Math.min(xd, yd, zd);
            if (k === xd) {
                return x;
            } else if (k === zd) {
                return z;
            } else {
                return y;
            }
        } else {
            return year;
        }
    };
    reorder = function(d) {
        if (d) {
            if (d && d.length === 3 && d[1] > 12) {
                return [ d[0], d[2], d[1] ];
            } else if (d && (d.length === 2 && d[1] > 12) || d.length === 1 && d[0] < 999) {
                return void 0;
            } else {
                return d;
            }
        }
    };
    validate = function(d) {
        if (d && !(d.length > 1 && (d[1] < 1 || d[1] > 12) || d.length > 2 && (d[2] < 1 || d[2] > 31))) {
            return d;
        }
    };
    isDatePart = function(t) {
        return typeof t === "string" && (t.length > 1 || t.match(/\d/));
    };
    module.exports = extractDates;
}).call(this);