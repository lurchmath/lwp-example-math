
# Lurch Web Platform, Math Example Application

This is an example application built on the
[Lurch Web Platform](https://github.com/lurchmath/lurch),
to show developers how to use that platform.  It assumes you've already
seen and understood some more simple examples,
[the first one](https://github.com/lurchmath/lwp-example-simple) and
[the second one](https://github.com/lurchmath/lwp-example-complex).

[Visit the live app here.](https://lurchmath.github.io/lwp-example-math)
It has a few features related to mathematics, to showcase how you can
include such things in your own applications.

To insert an equation:

 * Click the f(x) button on the toolbar to insert an equation.
 * Use the equation editor to type something, such at 15*6-3.

To work with the equation's meaning:

 * Highlight the equation with your cursor and click the `[ ]` button on the
   toolbar.  (Or, you could have clicked that first, then insert the
   equation inside it.)
 * Click the tag of the bubble that appears (or right-click within the
   bubble.)
 * The menu that appears will have two commands relevant to the mathematics
   you typed: "See full OpenMath structure" and "Evaluate this."

Seeing OpenMath:

 * If you click "See full OpenMath structure," the application will give you
   a popup dialog showing you the OpenMath XML encoding of the meaning of
   the mathematics you typed.
 * For those unfamiliar with OpenMath, see its specification document
   [here](http://www.openmath.org/standard/om20-2004-06-30/).

Evaluating expressions:

 * If you click "Evaluate this," the application will attempt to evaluate
   the expression you typed.
 * The result is shown in a popup dialog.

Read the (heavily commented) code here:

 * [App code](lwp-example-math.litcoffee) for this specific example
 * [HTML code](index.html) that loads the platform and application

There is also a very simple [build process](gulpfile.litcoffee).
