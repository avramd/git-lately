# git-lately
CLI script that offers a list of recently checked out git refs to quickly jump back to.

Requires ruby >= 2.6 (untested on ruby 3.x)

### Usage
Usage: git-lately.rb [-b] [-n NUMREFS]

Git-lately will:
- print out a list of the most recent git refs that anyone has checked out in the current repository.
- prefix each with a 1-character label. 
- prompt for the label of a ref in the list to checkout
- exit with no action on any other input (e.g. q, ESC, <return>)

Git-lately will prompt you for a label to check out for you. Any input other 
than a listed label with exit git-lately with no action.

### Example
```
➜  git-lately git:(master) ./git-lately
(9 seconds ago ) 0:master
(14 seconds ago) 1:a8be169a
(32 seconds ago) 2:another-dummy-branch
(40 seconds ago) 3:dummy-branch
Checkout above ref (0-9a-f)? 3
Switched to branch 'dummy-branch'
➜  git-lately git:(dummy-branch)
```

### Credit
Inspired by and original logic by [@marktabler](https://github.com/marktabler).
