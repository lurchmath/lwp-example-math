
# Mathematical Example Application, Lurch Web Platform

## Overview

To know what's going on here, you should first have read the documenation
for [the simple example application](simple-example-solo.litcoffee) and then
for [the complex example application](complex-example-solo.litcoffee).

This application, too, is an example application built on the [Lurch Web
Platform (LWP)](https://github.com/lurchmath/lurch), but it is more
interesting than the two above, because it shows how to incorporate an
equation editor and OpenMath semantics into an application (albeit in a
very simple way).

    setAppName 'MathApp'
    addHelpMenuSourceCodeLink \
        'lwp-example-math/blob/master/lwp-example-math.litcoffee'
    window.helpAboutText =
        '<p>See the fully documented <a target="top"
        href="https://github.com/lurchmath/lwp-example-math/blob/master/lwp-example-math.litcoffee"
        >source code for this demo app</a>.</p>'

[A live version of this app is online here.](https://lurchmath.github.io/lwp-example-math)

This application needs the equation editor plugin, so we must tell the setup
script to load it, by modifying the following global variable.

    window.pluginsToLoad.push 'equationeditor'

## Define one group type

This initialization code is similar to that in the two simpler example
applications linked to above.  This file assumes you've read those.

    window.groupTypes = [
        name : 'me'
        text : 'Mathematical Expression'
        tooltip : 'Make the selection a mathematical expression'
        color : '#666699'
        imageHTML : '<font color="#666699"><b>[ ]</b></font>'
        openImageHTML : '<font color="#666699"><b>[</b></font>'
        closeImageHTML : '<font color="#666699"><b>]</b></font>'

The `contentsChanged` function is called on a group whenever that group just
had its contents changed.  In this case, we analyze the contents of the
bubble tag and store the results of that analysis in the group.

The `inspect` function is central here, and is defined in [the following
section](#utility-functions-used-by-the-code-above).  It returns an
[OpenMath](http://www.openmath.org) data structure (as defined in [the
OpenMath JavaScript repository](https://github.com/lurchmath/openmath-js)),
which we can inspect to learn about the semantics of the group contents.

        contentsChanged : ( group, firstTime ) ->
            info = inspect group
            if info instanceof window.OMNode
                info = switch info.type

Label all basic types with the name of the basic type itself:

                    when 'i' then 'integer'
                    when 'f' then 'float'
                    when 'st' then 'string'
                    when 'ba' then 'byte array'
                    when 'sy' then 'symbol'
                    when 'v' then 'variable'

Label a function application with a name determined by the function or
operator being applied:

                    when 'a' then switch info.children[0].simpleEncode()
                        when 'arith1.plus', 'arith1.sum' then 'sum'
                        when 'arith1.minus' then 'difference'
                        when 'arith1.plusminus' then 'sum/difference'
                        when 'arith1.times' then 'product'
                        when 'arith1.divide' then 'quotient'
                        when 'arith1.power' then 'exponentiation'
                        when 'arith1.root' then 'radical'
                        when 'arith1.abs' then 'absolute value'
                        when 'arith1.unary_minus' then 'negation'
                        when 'relation1.eq' then 'equation'
                        when 'relation1.approx' then 'approximation'
                        when 'relation1.neq' then 'negated equation'
                        when 'relation1.lt', 'relation1.le', \
                             'relation1.gt', 'relation1.ge'
                            'inequality'
                        when 'logic1.not' then 'negated sentence'
                        when 'calculus1.int' then 'indefinite integral'
                        when 'calculus1.defint' then 'definite integral'
                        when 'transc1.sin', 'transc1.cos', 'transc1.tan', \
                             'transc1.cot', 'transc1.sec', 'transc1.csc'
                            'trigonometric function'
                        when 'transc1.arcsin', 'transc1.arccos', \
                             'transc1.arctan', 'transc1.arccot', \
                             'transc1.arcsec', 'transc1.arccsc'
                            'inverse trigonometric function'
                        when 'overarc' then 'overarc'
                        when 'overline' then 'overline'
                        when 'd.diff' then 'differential'
                        when 'interval1.interval_oo', \
                             'interval1.interval_oc', \
                             'interval1.interval_co', \
                             'interval1.interval_cc' then 'interval'
                        when 'integer1.factorial' then 'factorial'
                        when 'limit1.limit' then 'limit'

Label a binding expression as a lambda closure, since that's the only kind
supported by this application:

                    when 'b' then 'lambda closure'

We store the results of the inpection in an attribute of the group, so that
it's easy to look up later, when we need to place it in the bubble tag.

            group.set 'tag', info

When the application requests that we compute the group's tag, we just lift
the data out of the result already stored in the group from the above
computation, and use that as the contents of the bubble tag.

        tagContents : ( group ) -> group.get 'tag'

Clicking the tag or the context menu brings up the same menu, defined in
[the menu function below](#utility-functions-used-by-the-code-above).

        tagMenuItems : ( group ) -> menu group
        contextMenuItems : ( group ) -> menu group
    ]

## Utility functions used by the code above

The `inspect` function tries to interpret the contents of the group as
containing a single [MathQuill](http://mathquill.com/) instance.  (The LWP
comes with the built-in ability to insert MathQuill instances into documents
as WYSIWYG math expression editors.  It resides in the [eqed](eqed/) folder,
imported from [the LWP
repository](https://github.com/lurchmath/lurch/tree/master/source/assets/eqed).)

The `inspect` function returns one of two things.
 * If it returns an `OMNode` instance, it will be the meaning of the one
   MathQuill instance in the bubble, implying that there is one such
   instance in the group, and a meaning is parseable from it using [the
   MathQuill parser defined in the
   LWP](https://github.com/lurchmath/lurch/blob/master/source/auxiliary/mathquill-parser.litcoffee).
 * If an error arose in attempting such a computation, then a string will
   be returned containing the error.


    inspect = ( group ) ->
        nodes = $ group.contentNodes()
        selector = '.mathquill-rendered-math'
        nodes = nodes.find( selector ).add nodes.filter selector
        if nodes.length is 0 then return 'add math using the f(x) button'
        if nodes.length > 1 then return 'more than one math expression'
        try
            toParse = window.mathQuillToMeaning nodes.get 0
        catch e
            return "Error converting math expression to text: #{e?.message}"
        try
            parsed = mathQuillParser.parse( toParse )?[0]
        catch e
            return "Error parsing math expression as text: #{e?.message}"
        if parsed instanceof OMNode then return parsed
        "Could not parse this mathematical text: #{toParse?.join? ' '} --
            Error: #{parsed}"

The following function provides the contents of either the tag menu or the
context menu for a group; both are the same.  They contain two menu items.

    menu = ( group ) -> [

The first shows the full OpenMath structure of a group's meaning, as XML.
It uses the `toXML` function defined [near the end of the OpenMath
module](https://github.com/lurchmath/openmath-js/blob/master/openmath.litcoffee#converting-mathematical-expressions-to-xml).

        text : 'See full OpenMath structure'
        onclick : ->
            if ( info = inspect group ) not instanceof OMNode
                alert "Could not understand the bubble contents:\n #{info}"
            else
                try
                    alert info.toXML() ? "This demo could not convert some
                        part of that expression to XML."
                catch e then alert e.message ? e

The second is for evaluating the group's contents, as a mathematical
expression.  It uses the `evaluate` function defined [at the end of the
OpenMath
module](https://github.com/lurchmath/openmath-js/blob/master/openmath.litcoffee#evaluating-mathematical-expressions-numerically).

    ,
        text : 'Evaluate this'
        onclick : ->
            if ( info = inspect group ) not instanceof OMNode
                info = "Could not understand the bubble contents:\n#{info}"
            else
                result = info.evaluate()
                info = "#{result.value}"
                if result.message?
                    info += "\n\nNote:\n#{result.message}"
            alert info
    ]
