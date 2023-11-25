# git-lately
CLI script that offers a list of recently checked out git refs to quickly jump back to.

Usage: git-lately.rb

Git-lately will print out a list of the most recent git refs that anyone has
checked out in the current repository. Each will have a 1-character label. 

Git-lately will prompt you for a label to check out for you. Any input other 
than a listed label with exit git-lately with no action.
