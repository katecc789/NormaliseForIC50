# How to contribute

I'm glad you're reading this because I am still learning to collaborate. Thank you for joining me on this journey.

Here are some important resources:
- The basic idea behind our neutralisation assays at [Ferrara and Temperton, Methods Protoc. 2018](https://www.mdpi.com/2409-9279/1/1/8)
- Extremely helpful basics on how to submit a PR by [Fireship](https://www.youtube.com/watch?v=8lGpZkjnkt4).

## Submitting changes

Please send a [GitHub Pull Request to NormaliseForIC50](https://github.com/opengovernment/opengovernment/pull/new/master) with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)). 

- When you send a pull request, we will love you forever if you include a unittest using [testthat](https://testthat.r-lib.org/). We can always use more test coverage.
- Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).
- Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability:

  * Name files, functions, and variables sensibly. [Guide by Hadley Wickham](http://adv-r.had.co.nz/Style.html)
  * **AVOID** using absolute paths and `setwd()` in your script!
    * If you're programming a cooking robot, you wouldn't start them by programming how to get from your front door to your kitchen!
      * The robot will end up in another room, or run into a wall because you have different interior designs. (The other user's computer will not share the same file structure as yours)
      * It is not wise to let other people know the interior design of your house (file system).
    * instead use the magic of the **[here](https://here.r-lib.org/)** package to start at the top-level of current project.
      * Examples can be found on [how to use here::here on a .Rmd](https://here.r-lib.org/articles/rmarkdown.html), and this nice [ode](https://github.com/jennybc/here_here).
  * We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x += 1`, not `x+=1`), and around hash arrows.
  * This is open-source software. Consider the people who will read your code, and make it look nice for them. It's like driving a car: Perhaps you love doing donuts when you're alone, but with passengers, the goal is to make the ride as smooth as possible.

Thanks,  
Mark TK Cheng  
Visiting Researcher at CITIID and Student Doctor at the University of Cambridge

This contributing guideline is heavily based on [Open Government's contributing guidelines](https://github.com/opengovernment/opengovernment/blob/master/CONTRIBUTING.md?plain=1).
