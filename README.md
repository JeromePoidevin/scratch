scratch
=======

my 1st repo

=======

git remote add -m master scratch git@github.com:JeromePoidevin/scratch.git
git branch --set-upstream scratch scratch/master

git add
git commit -a

git clone https://github.com/JeromePoidevin/scratch.git
git clone ssh://git@github.com/JeromePoidevin/scratch.git
git diff
git push
git pull

http://stackoverflow.com/questions/5989893/github-how-to-checkout-my-own-repository
git clone [link to repo here]

http://stackoverflow.com/questions/7438313/pushing-to-git-returning-error-code-403-fatal-http-request-failed
git remote set-url <name> git@github.com:<username>/<repo>.git

https://help.github.com/articles/https-cloning-errors
git remote -v
# View existing remotes
# origin  https://github.com/github/reactivecocoa.git (fetch)
# origin  https://github.com/github/reactivecocoa.git (push)
git remote set-url origin https://github.com/github/ReactiveCocoa.git
# Change the 'origin' remote URL
git remote -v
# Verify new remote URL
# origin  https://github.com/github/ReactiveCocoa.git (fetch)
# origin  https://github.com/github/ReactiveCocoa.git (push)

