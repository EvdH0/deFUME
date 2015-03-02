<?php
# Always include this file
include "cbs_std.php";
# Create a html header, give the title
standard_head("deFUME-1.0 server");

?>
<style type="text/css">
    .none {
        display: none;
    }

    ,
    .showDIV {
        display: block;
    }
</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/themes/smoothness/jquery-ui.css"/>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/jquery-ui.min.js"></script>
<script>
/* Modernizr 2.8.3 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-canvas-canvastext-inputtypes-shiv-cssclasses-load
 */
;
window.Modernizr = function (a, b, c) {
    function v(a) {
        j.cssText = a
    }

    function w(a, b) {
        return v(prefixes.join(a + ";") + (b || ""))
    }

    function x(a, b) {
        return typeof a === b
    }

    function y(a, b) {
        return!!~("" + a).indexOf(b)
    }

    function z(a, b, d) {
        for (var e in a) {
            var f = b[a[e]];
            if (f !== c)return d === !1 ? a[e] : x(f, "function") ? f.bind(d || b) : f
        }
        return!1
    }

    function A() {
        e.inputtypes = function (a) {
            for (var d = 0, e, f, h, i = a.length; d < i; d++)k.setAttribute("type", f = a[d]), e = k.type !== "text", e && (k.value = l, k.style.cssText = "position:absolute;visibility:hidden;", /^range$/.test(f) && k.style.WebkitAppearance !== c ? (g.appendChild(k), h = b.defaultView, e = h.getComputedStyle && h.getComputedStyle(k, null).WebkitAppearance !== "textfield" && k.offsetHeight !== 0, g.removeChild(k)) : /^(search|tel)$/.test(f) || (/^(url|email)$/.test(f) ? e = k.checkValidity && k.checkValidity() === !1 : e = k.value != l)), o[a[d]] = !!e;
            return o
        }("search tel url email datetime date month week time datetime-local number range color".split(" "))
    }

    var d = "2.8.3", e = {}, f = !0, g = b.documentElement, h = "modernizr", i = b.createElement(h), j = i.style, k = b.createElement("input"), l = ":)", m = {}.toString, n = {}, o = {}, p = {}, q = [], r = q.slice, s, t = {}.hasOwnProperty, u;
    !x(t, "undefined") && !x(t.call, "undefined") ? u = function (a, b) {
        return t.call(a, b)
    } : u = function (a, b) {
        return b in a && x(a.constructor.prototype[b], "undefined")
    }, Function.prototype.bind || (Function.prototype.bind = function (b) {
        var c = this;
        if (typeof c != "function")throw new TypeError;
        var d = r.call(arguments, 1), e = function () {
            if (this instanceof e) {
                var a = function () {
                };
                a.prototype = c.prototype;
                var f = new a, g = c.apply(f, d.concat(r.call(arguments)));
                return Object(g) === g ? g : f
            }
            return c.apply(b, d.concat(r.call(arguments)))
        };
        return e
    }), n.canvas = function () {
        var a = b.createElement("canvas");
        return!!a.getContext && !!a.getContext("2d")
    }, n.canvastext = function () {
        return!!e.canvas && !!x(b.createElement("canvas").getContext("2d").fillText, "function")
    };
    for (var B in n)u(n, B) && (s = B.toLowerCase(), e[s] = n[B](), q.push((e[s] ? "" : "no-") + s));
    return e.input || A(), e.addTest = function (a, b) {
        if (typeof a == "object")for (var d in a)u(a, d) && e.addTest(d, a[d]); else {
            a = a.toLowerCase();
            if (e[a] !== c)return e;
            b = typeof b == "function" ? b() : b, typeof f != "undefined" && f && (g.className += " " + (b ? "" : "no-") + a), e[a] = b
        }
        return e
    }, v(""), i = k = null, function (a, b) {
        function l(a, b) {
            var c = a.createElement("p"), d = a.getElementsByTagName("head")[0] || a.documentElement;
            return c.innerHTML = "x<style>" + b + "</style>", d.insertBefore(c.lastChild, d.firstChild)
        }

        function m() {
            var a = s.elements;
            return typeof a == "string" ? a.split(" ") : a
        }

        function n(a) {
            var b = j[a[h]];
            return b || (b = {}, i++, a[h] = i, j[i] = b), b
        }

        function o(a, c, d) {
            c || (c = b);
            if (k)return c.createElement(a);
            d || (d = n(c));
            var g;
            return d.cache[a] ? g = d.cache[a].cloneNode() : f.test(a) ? g = (d.cache[a] = d.createElem(a)).cloneNode() : g = d.createElem(a), g.canHaveChildren && !e.test(a) && !g.tagUrn ? d.frag.appendChild(g) : g
        }

        function p(a, c) {
            a || (a = b);
            if (k)return a.createDocumentFragment();
            c = c || n(a);
            var d = c.frag.cloneNode(), e = 0, f = m(), g = f.length;
            for (; e < g; e++)d.createElement(f[e]);
            return d
        }

        function q(a, b) {
            b.cache || (b.cache = {}, b.createElem = a.createElement, b.createFrag = a.createDocumentFragment, b.frag = b.createFrag()), a.createElement = function (c) {
                return s.shivMethods ? o(c, a, b) : b.createElem(c)
            }, a.createDocumentFragment = Function("h,f", "return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&(" + m().join().replace(/[\w\-]+/g, function (a) {
                return b.createElem(a), b.frag.createElement(a), 'c("' + a + '")'
            }) + ");return n}")(s, b.frag)
        }

        function r(a) {
            a || (a = b);
            var c = n(a);
            return s.shivCSS && !g && !c.hasCSS && (c.hasCSS = !!l(a, "article,aside,dialog,figcaption,figure,footer,header,hgroup,main,nav,section{display:block}mark{background:#FF0;color:#000}template{display:none}")), k || q(a, c), a
        }

        var c = "3.7.0", d = a.html5 || {}, e = /^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i, f = /^(?:a|b|code|div|fieldset|h1|h2|h3|h4|h5|h6|i|label|li|ol|p|q|span|strong|style|table|tbody|td|th|tr|ul)$/i, g, h = "_html5shiv", i = 0, j = {}, k;
        (function () {
            try {
                var a = b.createElement("a");
                a.innerHTML = "<xyz></xyz>", g = "hidden"in a, k = a.childNodes.length == 1 || function () {
                    b.createElement("a");
                    var a = b.createDocumentFragment();
                    return typeof a.cloneNode == "undefined" || typeof a.createDocumentFragment == "undefined" || typeof a.createElement == "undefined"
                }()
            } catch (c) {
                g = !0, k = !0
            }
        })();
        var s = {elements: d.elements || "abbr article aside audio bdi canvas data datalist details dialog figcaption figure footer header hgroup main mark meter nav output progress section summary template time video", version: c, shivCSS: d.shivCSS !== !1, supportsUnknownElements: k, shivMethods: d.shivMethods !== !1, type: "default", shivDocument: r, createElement: o, createDocumentFragment: p};
        a.html5 = s, r(b)
    }(this, b), e._version = d, g.className = g.className.replace(/(^|\s)no-js(\s|$)/, "$1$2") + (f ? " js " + q.join(" ") : ""), e
}(this, this.document), function (a, b, c) {
    function d(a) {
        return"[object Function]" == o.call(a)
    }

    function e(a) {
        return"string" == typeof a
    }

    function f() {
    }

    function g(a) {
        return!a || "loaded" == a || "complete" == a || "uninitialized" == a
    }

    function h() {
        var a = p.shift();
        q = 1, a ? a.t ? m(function () {
            ("c" == a.t ? B.injectCss : B.injectJs)(a.s, 0, a.a, a.x, a.e, 1)
        }, 0) : (a(), h()) : q = 0
    }

    function i(a, c, d, e, f, i, j) {
        function k(b) {
            if (!o && g(l.readyState) && (u.r = o = 1, !q && h(), l.onload = l.onreadystatechange = null, b)) {
                "img" != a && m(function () {
                    t.removeChild(l)
                }, 50);
                for (var d in y[c])y[c].hasOwnProperty(d) && y[c][d].onload()
            }
        }

        var j = j || B.errorTimeout, l = b.createElement(a), o = 0, r = 0, u = {t: d, s: c, e: f, a: i, x: j};
        1 === y[c] && (r = 1, y[c] = []), "object" == a ? l.data = c : (l.src = c, l.type = a), l.width = l.height = "0", l.onerror = l.onload = l.onreadystatechange = function () {
            k.call(this, r)
        }, p.splice(e, 0, u), "img" != a && (r || 2 === y[c] ? (t.insertBefore(l, s ? null : n), m(k, j)) : y[c].push(l))
    }

    function j(a, b, c, d, f) {
        return q = 0, b = b || "j", e(a) ? i("c" == b ? v : u, a, b, this.i++, c, d, f) : (p.splice(this.i++, 0, a), 1 == p.length && h()), this
    }

    function k() {
        var a = B;
        return a.loader = {load: j, i: 0}, a
    }

    var l = b.documentElement, m = a.setTimeout, n = b.getElementsByTagName("script")[0], o = {}.toString, p = [], q = 0, r = "MozAppearance"in l.style, s = r && !!b.createRange().compareNode, t = s ? l : n.parentNode, l = a.opera && "[object Opera]" == o.call(a.opera), l = !!b.attachEvent && !l, u = r ? "object" : l ? "script" : "img", v = l ? "script" : u, w = Array.isArray || function (a) {
        return"[object Array]" == o.call(a)
    }, x = [], y = {}, z = {timeout: function (a, b) {
        return b.length && (a.timeout = b[0]), a
    }}, A, B;
    B = function (a) {
        function b(a) {
            var a = a.split("!"), b = x.length, c = a.pop(), d = a.length, c = {url: c, origUrl: c, prefixes: a}, e, f, g;
            for (f = 0; f < d; f++)g = a[f].split("="), (e = z[g.shift()]) && (c = e(c, g));
            for (f = 0; f < b; f++)c = x[f](c);
            return c
        }

        function g(a, e, f, g, h) {
            var i = b(a), j = i.autoCallback;
            i.url.split(".").pop().split("?").shift(), i.bypass || (e && (e = d(e) ? e : e[a] || e[g] || e[a.split("/").pop().split("?")[0]]), i.instead ? i.instead(a, e, f, g, h) : (y[i.url] ? i.noexec = !0 : y[i.url] = 1, f.load(i.url, i.forceCSS || !i.forceJS && "css" == i.url.split(".").pop().split("?").shift() ? "c" : c, i.noexec, i.attrs, i.timeout), (d(e) || d(j)) && f.load(function () {
                k(), e && e(i.origUrl, h, g), j && j(i.origUrl, h, g), y[i.url] = 2
            })))
        }

        function h(a, b) {
            function c(a, c) {
                if (a) {
                    if (e(a))c || (j = function () {
                        var a = [].slice.call(arguments);
                        k.apply(this, a), l()
                    }), g(a, j, b, 0, h); else if (Object(a) === a)for (n in m = function () {
                        var b = 0, c;
                        for (c in a)a.hasOwnProperty(c) && b++;
                        return b
                    }(), a)a.hasOwnProperty(n) && (!c && !--m && (d(j) ? j = function () {
                        var a = [].slice.call(arguments);
                        k.apply(this, a), l()
                    } : j[n] = function (a) {
                        return function () {
                            var b = [].slice.call(arguments);
                            a && a.apply(this, b), l()
                        }
                    }(k[n])), g(a[n], j, b, n, h))
                } else!c && l()
            }

            var h = !!a.test, i = a.load || a.both, j = a.callback || f, k = j, l = a.complete || f, m, n;
            c(h ? a.yep : a.nope, !!i), i && c(i)
        }

        var i, j, l = this.yepnope.loader;
        if (e(a))g(a, 0, l, 0); else if (w(a))for (i = 0; i < a.length; i++)j = a[i], e(j) ? g(j, 0, l, 0) : w(j) ? B(j) : Object(j) === j && h(j, l); else Object(a) === a && h(a, l)
    }, B.addPrefix = function (a, b) {
        z[a] = b
    }, B.addFilter = function (a) {
        x.push(a)
    }, B.errorTimeout = 1e4, null == b.readyState && b.addEventListener && (b.readyState = "loading", b.addEventListener("DOMContentLoaded", A = function () {
        b.removeEventListener("DOMContentLoaded", A, 0), b.readyState = "complete"
    }, 0)), a.yepnope = k(), a.yepnope.executeStack = h, a.yepnope.injectJs = function (a, c, d, e, i, j) {
        var k = b.createElement("script"), l, o, e = e || B.errorTimeout;
        k.src = a;
        for (o in d)k.setAttribute(o, d[o]);
        c = j ? h : c || f, k.onreadystatechange = k.onload = function () {
            !l && g(k.readyState) && (l = 1, c(), k.onload = k.onreadystatechange = null)
        }, m(function () {
            l || (l = 1, c(1))
        }, e), i ? k.onload() : n.parentNode.insertBefore(k, n)
    }, a.yepnope.injectCss = function (a, c, d, e, g, i) {
        var e = b.createElement("link"), j, c = i ? h : c || f;
        e.href = a, e.rel = "stylesheet", e.type = "text/css";
        for (j in d)e.setAttribute(j, d[j]);
        g || (n.parentNode.insertBefore(e, n), m(c, 0))
    }
}(this, document), Modernizr.load = function () {
    yepnope.apply(window, [].slice.call(arguments, 0))
};
</script>
<?php
# Create CBS menu. Format is:
# Keyword, Path, Name_of_this_page
# Keyword is the keyword for the menu color/area.
# Name_of_this_page is what this page is called in the hieraki
# Path format is a number of comma separated entries in parenthesis
# showing the path to this page; (services/,'CBS Prediction Servers')
standard_menu("CBSPS", "(services/,'CBS Prediction Servers')", "deFUME");
define_blink();
?>


<!-- START INDHOLD -->

<h1>deFUME 1.0 - Dynamic Exploration of Functional Metagenomics Sequencing Data
</h1>


<script>


    if (!Modernizr.canvas) {
        alert('Your current browser doesnt support the HTML5 canvas function, using deFUME to visualize your data will not be optimal. Please update to the latest version of your browser');

    }


    if (!Modernizr.inputtypes.range) {
        alert('Your browser doesnt support the HTML5 range function, using deFUME to visualize your data will not be optimal. Please update to the latest version of your browser');

    }

    if (!Modernizr.canvastext) {
        alert('Your browser doesnt support the HTML5 canvastext function, using deFUME to visualize your data will not be optimal. Please update to the latest version of your browser');

    }


</script>

<script>
    function setvalue(f, v) {
        document.getElementById(f).value = v;
    }
    function getvalue(f) {
        return document.getElementById(f).value;
    }

    function setTestMode() {
        $("#cv").addClass("none");
        $("#cv").removeClass("showDIV");
        $('#TEST').prop('checked', true);

        $("#explainTest").removeClass("none");
        $("#explainTest").addClass("showDIV")


        pasteVector();
        pasteForward();
        pasteReverse();

//Open vector field
        $("#sec4").toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom").find(".ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end().next().slideToggle();

    }
    function pasteVector() {
        document.getElementById('VEPASTE').value = ">pzE21\nctcgagtccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacatcagcaggacgcactgaccgaattcattaaagaggagaaaggtaccgggccccccctcgaggtcgacggtatcgataagcttgatatcgaattcctgcagcccgggggatcccatggtacgcgtgctagaggcatcaaataaaacgaaaggctcagtcgaaagactgggcctttcgttttatctgttgtttgtcggtgaacgctctcctgagtaggacaaatccgccgccctagacctagggcgttcggctgcggcgagcggtatcagctcactcaaaggcggtaatacggttatccacagaatcaggggataacgcaggaaagaacatgtgagcaaaaggccagcaaaaggccaggaaccgtaaaaaggccgcgttgctggcgtttttccataggctccgcccccctgacgagcatcacaaaaatcgacgctcaagtcagaggtggcgaaacccgacaggactataaagataccaggcgtttccccctggaagctccctcgtgcgctctcctgttccgaccctgccgcttaccggatacctgtccgcctttctcccttcgggaagcgtggcgctttctcaatgctcacgctgtaggtatctcagttcggtgtaggtcgttcgctccaagctgggctgtgtgcacgaaccccccgttcagcccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggtaagacacgacttatcgccactggcagcagccactggtaacaggattagcagagcgaggtatgtaggcggtgctacagagttcttgaagtggtggcctaactacggctacactagaaggacagtatttggtatctgcgctctgctgaagccagttaccttcggaaaaagagttggtagctcttgatccggcaaacaaaccaccgctggtagcggtggtttttttgtttgcaagcagcagattacgcgcagaaaaaaaggatctcaagaagatcctttgatcttttctacggggtctgacgctcagtggaacgaaaactcacgttaagggattttggtcatgactagtgcttggattctcaccaataaaaaacgcccggcggcaaccgagcgttctgaacaaatccagatggagttctgaggtcattactggatctatcaacaggagtccaagcgagctctcgaaccccagagtcccgctcagaagaactcgtcaagaaggcgatagaaggcgatgcgctgcgaatcgggagcggcgataccgtaaagcacgaggaagcggtcagcccattcgccgccaagctcttcagcaatatcacgggtagccaacgctatgtcctgatagcggtccgccacacccagccggccacagtcgatgaatccagaaaagcggccattttccaccatgatattcggcaagcaggcatcgccatgggtcacgacgagatcctcgccgtcgggcatgcgcgccttgagcctggcgaacagttcggctggcgcgagcccctgatgctcttcgtccagatcatcctgatcgacaagaccggcttccatccgagtacgtgctcgctcgatgcgatgtttcgcttggtggtcgaatgggcaggtagccggatcaagcgtatgcagccgccgcattgcatcagccatgatggatactttctcggcaggagcaaggtgagatgacaggagatcctgccccggcacttcgcccaatagcagccagtcccttcccgcttcagtgacaacgtcgagcacagctgcgcaaggaacgcccgtcgtggccagccacgatagccgcgctgcctcgtcctgcagttcattcagggcaccggacaggtcggtcttgacaaaaagaaccgggcgcccctgcgctgacagccggaacacggcggcatcagagcagccgattgtctgttgtgcccagtcatagccgaatagcctctccacccaagcggccggagaacctgcgtgcaatccatcttgttcaatcatgcgaaacgatcctcatcctgtctcttgatcagatcttgatcccctgcgccatcagatccttggcggcaagaaagccatccagtttactttgcagggcttcccaaccttaccagagggcgccccagctggcaattccgacgtctaagaaaccattattatcatgacattaacctataaaaataggcgtatcacgaggccctttcgtcttcac";
    }
    function pasteForward() {
        document.getElementById('FWDPRIMER').value = "FORWARD_";
    }
    function pasteReverse() {
        document.getElementById('REVPRIMER').value = "REVERSE_";
    }

</script>

<script>
    (function (i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r;
        i[r] = i[r] || function () {
            (i[r].q = i[r].q || []).push(arguments)
        }, i[r].l = 1 * new Date();
        a = s.createElement(o),
            m = s.getElementsByTagName(o)[0];
        a.async = 1;
        a.src = g;
        m.parentNode.insertBefore(a, m)
    })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

    ga('create', 'UA-57676915-1', 'auto');
    ga('send', 'pageview');

</script>

<script>
    function validateForm() {
        if (!validateEmail()) {
            alert("You have chosen not to provide an email address. Your job will run but it will not be annotated with GO and Interpro data.");
        }

        if (!validateDNA(document.getElementById('VEPASTE').value)) //Check if the Cloning vector sequence DNA, if entered, is correct
        {
            alert("The cloning vector sequence contains non DNA characters. Please only use ATCG");
            return false; //Kill on this one
        }

        if ((!validateAb1()) && (!validateNU()) && (!validateTEST())) {
            alert("No ab1 chromatogramfiles nor assembled nucleotide sequences were uploaded, please upload one of these OR select 'Load example test set'");
            return false;
        }

        return true; //No errors found, proceed


    }

    ////


    function validateEmail() {
        var x = document.forms["deFUMEform"]["EMAIL"].value;
        var atpos = x.indexOf("@");
        var dotpos = x.lastIndexOf(".");
        if (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= x.length) {
            return false;

            //return true;
        }
        else {
            return true;
        }


    }


    function validateDNA(seq) {

        // immediately remove trailing spaces
        seq = seq.trim();

        // split on newlines...
        var lines = seq.split('\n');

        // check for header
        if (seq[0] == '>') {
            // remove one line, starting at the first position
            lines.splice(0, 1);

        }

        // join the array back into a single string without newlines and
        // trailing or leading spaces
        seq = lines.join('').trim();

        //Search for charaters that are not G, A, T or C.
        if (seq.search(/[^gatc\s]/i) != -1) {
            //The seq string contains non-DNA characters
            return false;
            /// The next line can be used to return a cleaned version of the DNA
            /// return seq.replace(/[^gatcGATC]/g, "");
        }
        else {
            //The seq string contains only GATC
            return true;
        }

    }

    function validateAb1() {
        var x = document.forms["deFUMEform"]["ABSUB"].value;
        if (x == null || x == "") {
            return false;
        }
        else {
            return true;
        }

    }

    function validateNU() {
        //Verify if there is a paste or an textfield upload
        var x = document.forms["deFUMEform"]["NUSUB"].value;
        var y = document.forms["deFUMEform"]["NUPASTE"].value;
        if ((x == null || x == "") && (y == null || y == "")) {
            return false;
        }
        else {
            return true;
        }

    }

    function validateTEST() {
        if ($('#TEST').prop('checked')) {
            return true;
        } else {
            return false;
        }


    }

    function setUserdata() {
        $('#TEST').prop('checked', false);
        $("#cv").addClass("none");
        $("#cv").removeClass("showDIV");

        $("#explainTest").removeClass("showDIV");
        $("#explainTest").addClass("none");


    }
    function setAssembled() {
        $('#TEST').prop('checked', false);
        $("#cv").removeClass("none");
        $("#cv").addClass("showDIV");

        $("#explainTest").removeClass("showDIV");
        $("#explainTest").addClass("none");


    }

</script>

<!-- Server introduction text starts here -->

<p class="bulk">
    deFUME is a web service that assembles Sanger sequencing reads, identifies ORFs and blasts these as well as
    annotating them with InterPro.
    The results are shown as an interactive web-based report in table format.
<p>
    <!-- View the <a href="versions.html">version history</a> of this server. -->

<p>
    <!-- Server introduction text ends here -->

<p>

    <!-- Pink bar starts here -->

<table bgcolor="#FF3399" width="100%" border="0"
       cellpadding="0" cellspacing="0">
    <tr>

        <td bgcolor="#FF3399" width=50% align=center>   <!-- instructions.html -->
            <a href="instructions.php" target="_blank">
                <font color="#ffffff"><b>Instructions</b></font>
            </a>
        </td>

        <td width="2"><img src="/images/space_hvid.gif" width="2" height="18"></td>

        <td bgcolor="#FF3399" width=50% align=center>   <!-- abstract.html -->
            <a href="abstract.html">
                <font color="#ffffff"><b>Paper abstract</b></font>
            </a>
        </td>

    </tr>
</table>

<!-- Pink bar ends here -->

<br><p>

    <!-- Submission form starts here -->

<form enctype="multipart/form-data"
      action="/cgi-bin/webface2.fcgi"
      method="POST"
      name="deFUMEform"
      onsubmit="return validateForm()">
    <input type=HIDDEN name=configfile
           value="/usr/opt/www/pub/CBS/services/deFUME/deFUME.cf">


    <!-- AB1-FILE SUBMISSION -->

    <h3>SUBMISSION</h3>

    <div id="notaccordion">

        <h32 id="sec1"><strong>Upload sequences</strong></h32>
        <div>


            <p>deFUME takes ab1 files as input, in order to upload these to the server you first need to compress them
                in a zip or tar.gz file yourself. Read <a
                    href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#chromatogram" target="_BLANK">here</a>
                how to do this. </p>

            <p>
                <input type="radio" name="group1" value="userdata" checked onclick="setUserdata();">
                Raw sanger sequencing reads (ab1. format) compressed as zip or tar.gz. <a
                    href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#chromatogram" target="_BLANK"><img
                        src="/services/deFUME/visual/img/info.png" height="11" width="11"
                        title="Upload a tar.gz or zip file containing your chromatograms"></a><BR>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name="ABSUB" size="64" type="file">
            </p>

            <p>
                <input type="radio" name="group1" value="assembled" onclick="setAssembled();">Pre-assembled sequencing
                data <a href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#assembledcontig"
                        target="_BLANK"><img src="/services/deFUME/visual/img/info.png" height="11" width="11" title=""></a>
            </p>
            <div id="cv" class="none">

                <br>


                <!-- NUCLEOTIDE SEQUENCES ALREADY ASSEMBLED -->
                <h4>ASSEMBLED NUCLEOTIDE SEQUENCES</h4>
                <p>
                    Cannot be used with chromatogram or vector sequence submission.<br>
                    NOTE: Reads will not be shown on output visualization.<br><br>
                    <i>Paste a single nucleotide sequence or several sequences in
                        <a href="http://www.cbs.dtu.dk/services/fasta.example.html" target="_blank">FASTA</a>
                        format into the field below:</i></p>
                <br>
                <textarea name="NUPASTE" rows="3" cols="64"></textarea>

                <p>
                    <i>or upload a file in
                        <a href="http://www.cbs.dtu.dk/services/fasta.example.html" target="_blank">FASTA</a>
                        format directly from your local disk:</i>
                    <br>
                    <input name="NUSUB" size="64" type="file">
                    <br>
            </div>
            <p>
                <input type="radio" name="group1" value="testdata" onclick="setTestMode();">
                Load <a href="http://www.cbs.dtu.dk//services/deFUME/testdata/test.tar.gz">example data</a> set.

            <div id="explainTest" class="none">
                <p>If you don't want to run the test data but directly view the deFUME result, click <a
                        href="http://www.cbs.dtu.dk//services/deFUME/tmp/TESTSET/output.html">here</a></p>
            </div>

            <!-- CLONING VECTOR SUBMISSION -->



        </div>
        <h3 id="sec2"><strong>Recommended input</strong></h3>
        <div>

            <h4>PRIMER SEQUENCES</h4>

            <p>In order for deFUME to know which ab1 file is a forward and which is a reverse read you can enter a &quot;primer
                pattern&quot; below. For example if all your forward reads contain _F_ in the filename, enter that here.
                Separate multiple entries by comma, e.g. _OGEN41_,_F_</p>

            <p><br>
                <!-- FWDPRIMER -->
                Forward primer pattern:
                <input name="FWDPRIMER" size="20" id="FWDPRIMER">
                <a href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#primer" target="_BLANK"><img
                        src="/services/deFUME/visual/img/info.png" alt="" width="11" height="11"
                        title="Forward primer name pattern"></a><i>Optional</i> <br>
                <br>
                <!-- REVPRIMER -->
                Reverse primer pattern:
                <input name="REVPRIMER" size="20" id="REVPRIMER">
                <a href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#primer" target="_BLANK"><img
                        src="/services/deFUME/visual/img/info.png" alt="" width="11" height="11"
                        title="Reverse primer name pattern"></a><i>Optional</i></p>

            <h4>E-MAIL ADDRESS</h4>

            <p>deFUME uses the Interpro database at <a href="http://www.ebi.ac.uk/interpro/">EMBL-EBI</a> and this requires a
                valid mail address. If you don't provide an valid e-mail address deFUME will not include any GO annotations and
                Interpro links, severly limiting the vizualization of your dataset</p>

            <p>Email for InterPro queries:
                <input name="EMAIL" size="32">
                <a href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#email" target="_BLANK"><img
                        src="/services/deFUME/visual/img/info.png" height="11" width="11" title="Provide your email (REQUIRED)"></a><i>Optional</i>
            </p>

        </div>


        <h3 id="sec4"><a href="#"><b>Advanced input</b></a></h3>
        <div>
            <p><br>

            <h4>CLONING VECTOR SEQUENCE(S)</h4>
            <i>Paste a single nucleotide sequence or several sequences in
                <a href="http://www.cbs.dtu.dk/services/fasta.example.html" target="_blank">FASTA</a>
                format into the field below:</i>
            <br>
            <textarea name="VEPASTE" rows="3" cols="64" id="VEPASTE"></textarea>

            <p>
                <i>or upload a file in
                    <a href="http://www.cbs.dtu.dk/services/fasta.example.html" target="_blank">FASTA</a>
                    format directly from your local disk:</i>
                <br>
                <input name="VESUB" size="64" type="file">
                <br>


                <br><br>
                <!-- EMAIL FOR INTERPRO -->
                <br>
                <br><br>

                <!-- PHRED base calling error rate -->

                <b>Base calling error rate:</b> <br>
                Accuracy of base calls expressed as error probability. <br>
                The standard probability is 0.01, which corresponds to <br>
                a base call probability of 99% (or 1 error in 100 bases).<br>
                <input name="ERRORRATE" size="6">
                <a href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#basecalling" target="_BLANK"><img
                        src="/services/deFUME/visual/img/info.png" height="11" width="11" title="Error rate"> </a>
                <i>Optional</i>
                <br><br><br>

        </div>
    </div><BR>
    <i>deFUME will check your browser automatically for compatibility, read here <a
            href="http://www.cbs.dtu.dk//services/deFUME/instructions.php#browser" target="_BLANK"><img
                src="/services/deFUME/visual/img/info.png" height="11" width="11" title="Browser"></a> about the browser
        that were successfully tested.</i><br>
    <input type="submit" value="Submit">
    <input type="reset" value="Clear fields">
</p>
<p>
    <br>

    <br>
    <input name="TEST" id="TEST" type="checkbox" onclick="setTestMode();" style="opacity:0;">
</p>
</form>

<!-- Submission form ends here -->

<hr>

<!-- Reference starts here -->

<a name="citations">
    <h3>CITATIONS</h3>

    <p>For publication of results, please cite:
    <blockquote>
        <b><br>deFUME: Dynamic Exploration of Functional Metagenomic Sequencing Data</b><br>
        Eric van der Helm, Henrik Marcus Geertz-Hansen Hans Jasper Genee, Sailesh Malla, and Morten O. A. Sommer<br>
        {REFERENCE}
    </blockquote>
    </p>

    <!-- Reference ends here -->

    <script type="text/javascript">
        $.fn.togglepanels = function () {
            return this.each(function () {
                $(this).addClass("ui-accordion ui-accordion-icons ui-widget ui-helper-reset")
                    .find("h3")
                    .addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-top ui-corner-bottom")
                    .hover(function () {
                        $(this).toggleClass("ui-state-hover");
                    })
                    .prepend('<span class="ui-icon ui-icon-triangle-1-e"></span>')
                    .click(function () {
                        $(this)
                            .toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom")
                            .find("> .ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end()
                            .next().slideToggle();
                        return false;
                    })
                    .next()
                    .addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom")
                    .hide();


                $(this).addClass("ui-accordion ui-accordion-icons ui-widget ui-helper-reset")
                    .find("h32")
                    .addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-top ui-corner-bottom")
                    .hover(function () {
                        $(this).toggleClass("ui-state-hover");
                    })
                    .prepend('')
                    .next()
                    .addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom")
                    .hide();
            });
        };

        $("#notaccordion").togglepanels();
        $("#sec1").toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom").find(".ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end().next().slideToggle();
        $("#sec2").toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom").find(".ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end().next().slideToggle();
        $("#sec3").toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom").find(".ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end().next().slideToggle();
    </script>


    <?php
    # Displays a standard footer; two parameters:
    # First a simple headline like: "GETTING HELP:"
    # then a list of emails like this:
    # "('Tech assist','Frank','frank@foo.net'),('Scient assist','Bent','bent@foo.net')"
    standard_foot("GETTING HELP", "('Scientific problems','Eric van der Helm','evand@biosustain.dtu.dk'),('Technical problems','Henrik Marcus Geertz-Hansen','hmgh@cbs.dtu.dk')");
    ?>

